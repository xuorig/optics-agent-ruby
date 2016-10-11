module OpticsAgent
  module Normalization
    def empty_latency_count
      Array.new(256) { 0 }
    end

    # see https://github.com/apollostack/optics-agent/blob/master/docs/histograms.md
    def latency_bucket(nanos)
      micros = nanos * 1000
      bucket = Math.log(micros) / Math.log(1.1)

      [255, [0, bucket].max].min.ceil.to_i
    end
  end
end
