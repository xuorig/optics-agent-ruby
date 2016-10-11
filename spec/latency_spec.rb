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
        [0.0001, 0],
        [0.0009, 0],
        [0.001, 0],
        [0.0011, 1],
        [0.00121, 2],
        [0.100, 49],
        [1, 73],
        [1000, 145],
        [1.1**254 / 1000, 255],
        [1000 * 1000 * 1000 * 1000, 255]
      ]

      tests.each do |test|
        expect(latency_bucket test.first).to eq(test.last)
      end
    end
  end
end
