class Answer < ActiveRecord::Base
  belongs_to :question
  has_many :results
  after_validation :compile

  def compile
    # write source to file
    File.open(self.source_file, "w") do |f|
      f.write(self.answer)
    end

    Open3.popen3("gcc -o #{self.exec_file} #{self.source_file}") do |stdin, stdout, stderr|
      while error = stderr.gets
        self.errors.add("answer", error)
      end
    end
    return false unless self.errors.empty?
    exec
  end

  def exec
    # check answer
    self.results.destroy_all
    question.answer_patterns.each do |pattern|
      next if pattern.input == "" && pattern.expect_answer == ""
      result = Result.new(:pattern_id => pattern.id, :answer_id => self.id)
      judge = nil
      Open3.popen3("#{self.exec_file}") do |stdin, stdout, stderr, wait_thr|
        process_id = wait_thr.pid
        Thread.start(process_id, result) do |pid, result|
          sleep(3)
          unless Process.detach(pid).nil?
            Process.kill(:INT, pid) 
          end
        end

        stdin.write(pattern.input)
        stdin.close

        buffer = ""
        while output = stdout.gets
          buffer.concat(output)
        end

        if buffer == pattern.expect_answer.gsub("\r\n", "\n")
          result.result = "OK"
        else
          result.result = "Wrong Answer"
        end
      end
      result.save
    end
  end

  def source_file
    source_file_dir = File.join(Rails.root, "tmp/source_files")
    FileUtils.mkdir_p(source_file_dir)
    "#{source_file_dir}/#{self.id}.c"
  end

  def exec_file
    exec_file_dir = File.join(Rails.root, "tmp/exec_files")
    FileUtils.mkdir_p(exec_file_dir)
    "#{exec_file_dir}/#{self.id}.exe"
  end
end
