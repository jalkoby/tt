require 'test_helper'

class TTController < ActionController::Base
  public :tt
end

describe "ActionPack integration" do
  before do
    @controller = TTController.new
    @controller.run_callbacks(:process_action)
  end

  it 'returns tt instance if the method was called without args' do
    assert_equal @controller.tt.class, TT::Rails
  end

  it 'calls #t if args were passed' do
    load_i18n(common: { tar: 'global_tar' })
    assert_equal @controller.tt.c(:tar), 'global_tar'
  end
end
