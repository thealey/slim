require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  def new_person(attributes = {})
    attributes[:username] ||= 'foo'
    attributes[:email] ||= 'foo@example.com'
    attributes[:password] ||= 'abc123'
    attributes[:password_confirmation] ||= attributes[:password]
    attributes[:goal] ||= '190'
    attributes[:height_feet] ||= '6'
    attributes[:inches] ||= '4'
    person = Person.new(attributes)
    person.valid? # run validations
    person
  end

  def setup
    Person.delete_all
  end

  def test_valid
    assert new_person.valid?
  end

  def test_require_username
    assert_equal ["can't be blank"], new_person(:username => '').errors[:username]
  end

  def test_require_password
    assert_equal ["can't be blank","can't be blank"], new_person(:password => '').errors[:password]
  end

  def test_require_well_formed_email
    assert_equal ["is invalid"], new_person(:email => 'foo@bar@example.com').errors[:email]
  end

  def test_validate_uniqueness_of_email
    new_person(:email => 'bar@example.com').save!
    assert_equal ["has already been taken"], new_person(:email => 'bar@example.com').errors[:email]
  end

  def test_validate_odd_characters_in_username
    assert_equal ["should only contain letters, numbers, or .-_@"], new_person(:username => 'odd ^&(@)').errors[:username]
  end

  def test_validate_password_length
    assert_equal ["is too short (minimum is 4 characters)","is too short (minimum is 4 characters)"], new_person(:password => 'bad').errors[:password]
  end

  def test_require_matching_password_confirmation
    assert_equal ["doesn't match confirmation","doesn't match confirmation"], new_person(:password_confirmation => 'nonmatching').errors[:password]
  end
end
