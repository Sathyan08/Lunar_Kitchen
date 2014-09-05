class Ingredient
  attr_reader :name

  def initialize(ingredient_hash)
    @name = ingredient_hash["name"]

  end

end
