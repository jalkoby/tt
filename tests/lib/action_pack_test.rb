require 'test_helper'

class TTController < ActionController::Base
  public :tt
end

describe "ActionPack integration" do
  before do
    @controller = TTController.new
  end

  it 'returns tt instance if the method was called without args' do
    assert_equal @controller.tt.class, TT::Translator
  end

  it 'calls #t if args were passed' do
    assert_equal @controller.tt.c(:tar), 'global_tar'
  end
end
