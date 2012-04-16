require "ai4r"

REPORT_INTERVAL = ARGV[0].to_i
RUN_LENGTH = ARGV[1].nil? ? nil : ARGV[1].to_i

@net = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 2, 1])

def log(msg)
  warn("#{Time.now}: #{msg}")
end

def train
  log("Training...")
  training_file = File.new("_training.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
  line_number = 0
  while (line = training_file.gets)
    line.chomp!
    elements = line.split("\t")

    output = elements[0].to_f

    input = []
    for (i=1; i<elements.length; i++)
      input.push(elements[i])
    end

    @net.train(input, [output])

    line_number += 1
    if line_number % REPORT_INTERVAL == 0
      log("Processed #{line_number} lines...")
    end
  end
  log("OK")
end

def evaluate
  log("Evaluating...")
  submission_file = File.new("submission.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "w")
  test_file = File.new("_test.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
  line_number = 0
  while (line = test_file.gets)
    line.chomp!
    input = line.split("\t")

    output = @net.eval(input)
    submission_file.puts(output)

    line_number += 1
    if line_number % REPORT_INTERVAL == 0
      log("Processed #{line_number} lines...")
    end
  end
  submission_file.close
  log("OK")
end

train()
evaluate()

