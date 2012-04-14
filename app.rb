require 'rubygems'
require "ai4r"


# data = [
#      [[-1, -1],[ -1]],
#      [[-1, 1], [1]],
#      [[1, -1], [1]],
#      [[1, 1], [-1]]
#      ]

# data = [
#      [[.1, .1], [.01]],
#      [[.2, .2], [.04]],
#      [[.3, .3], [.09]],
#      [[.4, .4], [.16]]
#      ]

# 10.times do
#   # Train the network
#   data.length.times do |i|
#     net.train(data[i][0], data[i][1])
#   end
#   puts net.eval([5, 6])
# end

require 'ruby_fann/neural_network'

def fn(a, b)
    a * 0.2 + b * 0.8
end

inputs = []
outputs = []
10000.times do
  a = Random.rand()
  b = Random.rand()

  inputs.push([a, b])
  outputs.push([fn(a, b)])
end

net = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 2, 1])
   inputs.length.times do |i|
     net.train(inputs[i], outputs[i])
   end
   puts net.eval([0.4, 0.7])


# training_data = RubyFann::TrainData.new(
#   :inputs=>inputs,
#   :desired_outputs=>outputs)

# fann = RubyFann::Standard.new(
#   :num_inputs=>2,
#   :hidden_neurons=>[3, 3, 3],
#   :num_outputs=>1)

# fann.train_on_data(training_data, 1, 10, 0.1)

# sum = 0
# 1000.times do
# sum += fann.run([0.4, 0.7])[0]
# end

# puts sum/1000.0

puts fn(0.4, 0.7)
