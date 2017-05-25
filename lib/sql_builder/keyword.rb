module SQLBuilder
  class Keyword
    def initialize(name)
      @name = name
    end

    def to_s
      @name.to_s.upcase
    end
  end
end
