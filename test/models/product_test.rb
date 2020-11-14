require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "product attributes must not be empty" do 
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any? 
    assert product.errors[:price].any? 
    assert product.errors[:image_url].any?
    # Take a look at the values
    # puts "Description #{product.errors[:description]}"
    # puts "Price #{product.errors[:price]}"
    # puts "Image URL: #{product.errors[:image_url]}"
  end

  def new_product(image_url) 
    Product.new(title: "My Book Title", description: "yyy", price: 1, image_url: image_url)
  end

  test "image url" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }
    ok.each do |url|
      assert new_product(url).valid?, "#{url} shouldn't be invalid" 
    end
    bad.each do |url|
      assert new_product(url).invalid?, "#{url} shouldn't be valid"
    end 
  end
end