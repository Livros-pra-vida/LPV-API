class Bookcase < ApplicationRecord
  belongs_to :user
  has_many :books, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 },
                   uniqueness: { scope: :user_id, case_sensitive: false,
                                 message: "já existe uma estante com esse nome" }
  validates :limit, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 500 }

  def books_count
    books.size
  end

  def serializable_hash(options = nil)
    super({ except: [ :user_id ], methods: :books_count }.merge(options || {}))
  end
end
