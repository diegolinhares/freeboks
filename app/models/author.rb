class Author < ::ApplicationRecord
  include ::Litesearch::Model

  litesearch do |schema|
    schema.field :name
  end

  has_many :books,
           dependent: :destroy,
           inverse_of: :author

  with_options presence: true do
    validates :name, uniqueness: true
  end
end
