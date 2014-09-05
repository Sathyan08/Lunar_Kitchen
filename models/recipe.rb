require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end

class Recipe
  attr_reader :id, :name, :description, :instructions, :ingredients

  def initialize(recipe_hash)
    @name           = recipe_hash["name"]
    @id             = recipe_hash["id"]

    unless recipe_hash["description"].nil?
      @description  = recipe_hash["description"]
    else
      @description  = "This recipe doesn't have a description."
    end

    unless recipe_hash["instructions"].nil?
      @instructions = recipe_hash["instructions"]
    else
      @instructions = "This recipe doesn't have any instructions."
    end

    @ingredients  = []

    db_connection do |conn|
      @ingredients_list = conn.exec('SELECT * FROM ingredients WHERE recipe_id = $1', [@id])
    end

    @ingredients_list.each do |ingredient_hash|
      @ingredients << Ingredient.new(ingredient_hash)
    end

  end

  def self.all
    recipe_collection = []

    db_connection do |conn|
      @recipes = conn.exec('SELECT * FROM recipes')
    end
    @recipes.each do |recipe_hash|
      recipe_collection << Recipe.new(recipe_hash)
    end

    recipe_collection
  end

  def self.find(id)
    db_connection do |conn|
      @recipe_sought = conn.exec('SELECT * FROM recipes WHERE id = $1', [id])
    end
    Recipe.new(@recipe_sought[0])
  end

end
