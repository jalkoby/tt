require 'test_helper'

describe TT::Translator do
  before do
    @tt = TT::Translator.new("tt", "spec")
  end

  describe '#t' do
    it "looks for a section translation first" do
      assert_equal @tt.t(:foo), "spec_foo"
    end

    it "falls back to common namespace translations" do
      assert_equal @tt.t(:bar), "namespace_bar"
    end

    it "allows a custom options" do
      assert_equal @tt.t(:tar, default: "default_tar"), "default_tar"
    end
  end

  describe '#c' do
    it "looks for a namespace translation first" do
      assert_equal @tt.c(:foo), "namespace_foo"
    end

    it "falls back to a global translation" do
      assert_equal @tt.c(:tar), "global_tar"
    end

    it "allows a custom options" do
      assert_equal @tt.c(:car, default: "default_car"), 'default_car'
    end
  end

  describe '#f' do
    it "looks for a namespace translation first" do
      assert_equal @tt.f(:edit), "namespace_edit"
    end

    it "falls back to a global translation" do
      assert_equal @tt.f(:save), "global_save"
    end

    it "allows a custom options" do
      assert_equal @tt.f(:commit, default: "default_commit"), "default_commit"
    end
  end

  describe '#tip' do
    it "looks for a namespace translation first" do
      assert_equal @tt.tip(:info), "namespace_info"
    end

    it "falls back to a global translation" do
      assert_equal @tt.tip(:notice), "global_notice"
    end

    it "allows a custom options" do
      assert_equal @tt.tip(:tipsy, default: "default_tipsy"), "default_tipsy"
    end
  end

  describe '#crumb' do
    it "looks for a namespace translation first" do
      assert_equal @tt.crumb(:new), "namespace_new"
    end

    it "falls back to a global translation" do
      assert_equal @tt.crumb(:index), "global_index"
    end

    it "allows a custom options" do
      assert_equal @tt.crumb(:show, default: "default_show"), "default_show"
    end
  end

  describe 'a model related methods' do
    before do
      @klass = Minitest::Mock.new
    end

    describe '#attr' do
      it 'uses the provided class' do
        @klass.expect(:human_attribute_name, 'Nombre', [:name])
        assert_equal @tt.attr(:name, @klass), 'Nombre'
      end

      it 'uses a context class by default' do
        @klass.expect(:human_attribute_name, 'Nombre', [:name])
        @tt.stub(:context_klass, @klass) do
          assert_equal @tt.attr(:name), 'Nombre'
        end
      end
    end

    describe '#enum' do
      it 'uses the provided class' do
        @klass.expect(:human_attribute_name, 'Melody', ['type_melody'])
        assert_equal @tt.enum(:type, :melody, @klass), 'Melody'
      end

      it 'uses a context class by default' do
        @klass.expect(:human_attribute_name, 'Sound', ['type_sound'])
        @tt.stub(:context_klass, @klass) do
          assert_equal @tt.enum(:type, :sound), 'Sound'
        end
      end
    end

    describe 'a model name' do
      before do
        @model_name = Minitest::Mock.new
        @klass.expect(:model_name, @model_name)
      end

      describe '#resource' do
        before do
          @model_name.expect(:human, 'Coche', [{ count: 1 }])
        end

        it 'uses the provided class' do
          assert_equal @tt.resource(@klass), 'Coche'
        end

        it 'uses a context class by default' do
          @tt.stub(:context_klass, @klass) do
            assert_equal @tt.resource, 'Coche'
          end
        end
      end

      describe '#resources' do
        before do
          @model_name.expect(:human, 'Coches', [{ count: 10 }])
        end

        it 'uses the provided class' do
          assert_equal @tt.resources(@klass), 'Coches'
        end

        it 'uses a context class by default' do
          @tt.stub(:context_klass, @klass) do
            assert_equal @tt.resources, 'Coches'
          end
        end
      end

      describe '#no_resources' do
        before do
          @model_name.expect(:human, 'Coches', [{ count: 0 }])
        end

        it 'uses the provided class' do
          assert_equal @tt.no_resources(@klass), 'Coches'
        end

        it 'uses a context class by default' do
          @tt.stub(:context_klass, @klass) do
            assert_equal @tt.no_resources, 'Coches'
          end
        end
      end

      after do
        assert @model_name.verify
      end
    end

    after do
      assert @klass.verify
    end
  end
end
