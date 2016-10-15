require 'optics-agent/normalization/query'

TEST_QUERIES = [
  [
    'basic test',
    '{
      user {
        name
      }
    }',
    '{user {name}}',
  ],
  [
    'basic test with query',
    'query {
      user {
        name
      }
    }',
    '{user {name}}',
  ],
  [
    'basic with operation name',
    'query OpName {
      user {
        name
      }
    }',
    'query OpName {user {name}}',
  ],
  [
    'fragment',
    '{
      user {
        name
        ...Bar
      }
    }
    fragment Bar on User {
      asd
    }
    fragment Baz on User {
      jkl
    }',
    '{user {name ...Bar}} fragment Bar on User {asd}',
  ],
  [
    'full test',
    'query Foo ($b: Int, $a: Boolean){
      user(name: "hello", age: 5) {
        ... Bar
        ... on User {
          hello
          bee
        }
        tz
        aliased: name
      }
    }
    fragment Baz on User {
      asd
    }
    fragment Bar on User {
      age @skip(if: $a)
      ...Nested
    }
    fragment Nested on User {
      blah
    }',
    'query Foo($a:Boolean,$b:Int) {user(age:0, name:"") {name tz ...Bar ... on User {bee hello}}}' +
    ' fragment Bar on User {age @skip(if:$a) ...Nested} fragment Nested on User {blah}',
  ],
]


describe OpticsAgent::Normalization::Query do
  include OpticsAgent::Normalization::Query

  TEST_QUERIES.each do |spec|
    test_name, query, expected_signature = spec

    it test_name do
      signature = normalize(query)
      expect(signature).to eq(expected_signature)
    end
  end
end
