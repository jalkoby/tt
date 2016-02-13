require 'test_helper'

describe 'Methods related to models' do
  before do
    @tt = ARTranslator.new("admin/users", "spec")
  end

  describe 'actions' do
    before do
      load_i18n({
        actions: {
          base:  { do: 'Do', make: 'Do', execute: 'Do' },
          user:  {
            make: 'Make', execute: 'Make',
            subscribe: 'The %{r} will be subscribed with other %{rs} of this day. %{RS} get 10% off with the subscription.'
          },
          admin: { user: { execute: 'Execute' } }
        },
        models: { admin: { user: { one: "Admin", other: "Admins" } } }
      })
    end

    it 'returns a specific action' do
      assert_equal @tt.a(:execute), 'Execute'
    end

    it 'returns a pure model action' do
      assert_equal @tt.a(:make), 'Make'
    end

    it 'returns a base action' do
      assert_equal @tt.a(:do), 'Do'
    end

    it 'allows to specify a custom model' do
      assert_equal @tt.a(:execute, :user), 'Make'
    end

    it 'passes translations of a model' do
      assert_equal @tt.a(:subscribe), 'The admin will be subscribed with other admins of this day. Admins get 10% off with the subscription.'
    end
  end

  describe 'attributes' do
    before do
      load_i18n(attributes: {
        base:  { name: 'Name', phone: 'Phone', email: 'Email' },
        user:  { name: 'Nick', phone: 'Notification phone' },
        admin: { user: { name: 'Contact admin name' } }
      })
    end

    it 'returns a specific attribute' do
      assert_equal @tt.attr(:name), 'Contact admin name'
    end

    it 'returns a pure model attribute' do
      assert_equal @tt.attr(:phone), 'Notification phone'
    end

    it 'returns a base attribute' do
      assert_equal @tt.attr(:email), 'Email'
    end

    it 'allows to specify a custom model' do
      assert_equal @tt.attr(:name, :user), 'Nick'
    end
  end

  describe 'enums' do
    before do
      load_i18n(enums: {
        base: { gender: { f: 'Female', m: 'Male', o: 'Other' } },
        user: { gender: { f: 'Woman', m: 'Man' } },
        admin: { user: { gender: { f: 'Admin' } } }
      })
    end

    it 'returns a specific enum' do
      assert_equal @tt.enum(:gender, :f), 'Admin'
    end

    it 'returns a pure model enum' do
      assert_equal @tt.enum(:gender, :m), 'Man'
    end

    it 'returns a base enum' do
      assert_equal @tt.enum(:gender, :o), 'Other'
    end

    it 'allows to specify a custom model' do
      assert_equal @tt.enum(:gender, :f, :user), 'Woman'
    end
  end

  describe 'errors' do
    before do
      load_i18n(errors: {
        messages: { name: { blank: "should be filled" }, fields_missed: "not all required fields are filled" },
        user: { password: { weak: "Your password is weak" }, limit: 'The limit has been reached', duplicated: "The site has an account with the inputed information" },
        admin: { user: { email: { empty: "The admin email should be filled" }, limit: "The system has reached the admin limit" } }
      })
    end

    it 'returns a specific error' do
      assert_equal @tt.e(:email, :empty), 'The admin email should be filled'
    end

    it 'returns a specific base error' do
      assert_equal @tt.e(:base, :limit), 'The system has reached the admin limit'
    end

    it 'returns a pure model error' do
      assert_equal @tt.e(:password, :weak), 'Your password is weak'
    end

    it 'returns a base pure model error' do
      assert_equal @tt.e(:base, :duplicated), 'The site has an account with the inputed information'
    end

    it 'returns a base attribute error' do
      assert_equal @tt.e(:name, :blank), 'should be filled'
    end

    it 'returns a base error' do
      assert_equal @tt.e(:base, :fields_missed), 'not all required fields are filled'
      assert_equal @tt.e(:roo, :fields_missed), 'not all required fields are filled'
    end

    it 'allows to specify a custom model' do
      assert_equal @tt.e(:base, :limit, :user), 'The limit has been reached'
    end
  end

  describe 'resource names' do
    before do
      @tt = ARTranslator.new('public/people')
      load_i18n({
        models: { person: { one: "whatever", other: "whatever" }, user: { one: "User", other: "Users" } },
        activerecord: { models: {
          public: { person: { one: "Celebrity", other: "Celebrities" } },
          person: { one: "Person", other: "People" }
        } }
      })
    end

    it 'handles namespaces' do
      assert_equal @tt.r, 'Celebrity'
      assert_equal @tt.rs, 'Celebrities'
    end

    it 'looks inside orm namespace' do
      assert_equal @tt.r(:person), 'Person'
      assert_equal @tt.rs(:person), 'People'
    end

    it "fallbacks into base if orm namespace doesn't have a key" do
      assert_equal @tt.r(:user), 'User'
      assert_equal @tt.rs(:user), 'Users'
    end
  end
end
