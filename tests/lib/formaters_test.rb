require 'test_helper'
require 't_t/formaters'

describe "Formaters" do
  it 'prints csv output' do
    groups = { 'deserts.yml' => [{ 'en' => 'Apple', 'es' => 'Manzana' }, { 'es' => 'Dulce', 'en' => 'Candy' }] }
    begin
      TT::Formaters::CSV = Struct.new(:example) {
        def open(*args, &block)
          io = []
          block.call(io)
          example.assert_equal io.length, 3
          example.assert_equal io[0], ['EN', 'ES']
          example.assert_equal io[1], ['Apple', 'Manzana']
          example.assert_equal io[2], ['Candy', 'Dulce']
        end
      }.new(self)
      TT::Formaters.print(groups, 'csv')
    ensure
      TT::Formaters.send(:remove_const, :CSV)
    end
  end
end
