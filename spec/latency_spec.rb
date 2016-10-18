require 'optics-agent/normalization/latency'
include OpticsAgent::Normalization


describe 'latency helpers' do
  describe 'empty_latency_count' do
    it 'returns 256 zeros' do
      zeros = empty_latency_count
      expect(zeros.length).to equal(256)
      zeros.each { |z| expect(z).to eq(0) }
    end
  end

  describe 'latency_bucket' do
    it 'returns the right values' do
      tests = [
        [-1, 0],
        [0, 0],
        # 1 nanosecond
        [0.001, 0],
        [0.1, 0],
        [0.9, 0],
        [0.999, 0],
        # 1 microsecond
        [1, 0],
        [1.001, 1],
        [1.1, 1],
        [1.101, 2],
        [1.21, 2],
        [10, 25],
        [10.834, 25],
        [10.835, 26],
        [100, 49],
        # 1 millisecond
        [1000, 73],
        # 1 second
        [1000 * 1000, 145],
        [1.1**254, 255],
        # 5 days
        [5 * 24 * 60 * 60 * 1000 * 1000, 255],
        [1000 * 1000 * 1000 * 1000, 255]
      ]

      tests.each do |test|
        expect(latency_bucket test.first).to eq(test.last)
      end
    end
  end
end
