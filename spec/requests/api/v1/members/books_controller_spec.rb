require "rails_helper"

::RSpec.describe ::Api::V1::Members::BooksController, type: :request do
  fixtures :users, :books, :authors, :genres

  let(:samuel_tarly) { users(:samuel_tarly) }
  let(:api_access_token) { samuel_tarly.api_access_token }

  describe "GET /api/v1/members/books" do
    context "when authenticated" do
      it "returns paginated books for the current member" do
        get api_v1_members_books_path,
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expected_body = {
          status: "success",
          type: "object",
          data: {
            books: [
              hash_including(
                title: "A Feast for Crows",
                author_name: "George R. R. Martin",
                genre_name: "Fantasy"
              ),
              hash_including(
                title: "Dune",
                author_name: "Frank Herbert",
                genre_name: "Science Fiction"
              ),
              hash_including(
                title: "A Dance with Dragons",
                author_name: "George R. R. Martin",
                genre_name: "Fantasy"
              ),
              hash_including(
                title: "The Book Thief",
                author_name: "Markus Zusak",
                genre_name: "Historical Fiction"
              ),
              hash_including(
                title: "Gone Girl",
                author_name: "Gillian Flynn",
                genre_name: "Thriller"
              )
            ]
          },
          pagination: {
            count: 16,
            items: 5,
            next: 2,
            page: 1,
            pages: 4,
            prev: nil
          }
        }

        expect(body).to match(expected_body)
      end

      it "returns paginated books for the search query" do
        get api_v1_members_books_path(query: "Dune"),
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expected_body = {
          status: "success",
          type: "object",
          data: {
            books: [
              hash_including(
                title: "Dune",
                author_name: "Frank Herbert",
                genre_name: "Science Fiction"
              )
            ]
          },
          pagination: {
            count: 1,
            items: 5,
            next: nil,
            page: 1,
            pages: 1,
            prev: nil
          }
        }

        expect(body).to match(expected_body)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized status" do
        get api_v1_members_books_path, as: :json

        expect(response).to have_http_status(:unauthorized)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Invalid access token",
          details: {}
        )
      end
    end
  end
end
