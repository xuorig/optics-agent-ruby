module OpticsAgent
  class Transaction
    attr_reader :agent

    def initialize
      @query = OpticsAgent::Reporting::Query.new
      @agent = OpticsAgent::Agent.instance
    end

    def with_document(document)
      @query.document = document
      self
    end

    private

    attr_reader :query
  end
end
