# Dewey

Using the OpenLibrary api, you can save selected books to your "Ready List"

## Get Started

To easily run the project, we assume you are proficient enough to find the bundle ID in the Xcode project and change it to your own so that you can run the app on your own device. However, it is possible to run this on the simulator as well. We require the latest Xcode 26.4 to proceed.

## Assumptions

Since we wanted to use the API sparingly, we have limited all requests to the first 20 items as a limit. This can be refactored in the future. This is hardcoded in the `BookRespository` swift file.

## Project 

I've ensured that some of my favorite project settings were in place before beginning the project to set me up for success.

- Swift 6
- Strict Concurrency set to "complete"
- MainActor isolation by default
- Require Existential any to "Yes" under the "Swift Compiler - Upcoming Features"

### Project Structure

Since this is meant to be a small project, we have the source code for the target build in `Dewey/` and unit test separate in the `DeweyTests/` directories.

Under the `Dewey/` directory, we have the following organization:
- `Codable/` that hold structs that conform to Codable for use OpenLibrary api endpoints for JSON responses.
- `Models/` that hold the SwiftData models, migration plan, and `BookStore` for read/write/delete `BookRecord` objects to SwiftData.
- `Networking/` which contains the `BookFetcher`, `OpenLibraryBookFetcher`, and `NetworkData`
- `Views/` most of the app's views. The most important ones would be `SearchBookView`, `SavedBooksListView`, and `BookDetailView`.
- `DeweyApp` controls the setup of the scene for the app and serves as the main entry point to the SwiftUI views. It sets up the local persistance container and the `BookRepository` with a `LiveNetworkData` and `OpenLibraryBookFeater`, and `LocalBookStore`.

> `NetworkData` was created to isolate the calls to the network so that working with `#Preview` for views and unit testing was easier. We don't want use the `LiveNetworkData` for unit tests or for `#Preview`.

## Test Plan

I have set up a single test plan with a few unit tests called "UnitTests.xctestplan" at the root of the project.

## View Hierarchy

We have a TabView that lists two tabs: one for "Search" and one for reviewing the "Reading List".

### Search Tab

The Search tab is represented by the `SearchBookView`.

It uses the `BookRepository` from the `@Environment` to fetch for books that are entered into the search field using the `fetchBook(query: String) async` method. The results from that query are stored in the `private(set) var books: [BookRecord]` instance variable. When this variable changes, it forces a UI re-render to show the search results.

From this screen, you can do the following:
1. search for books by title
2. books that are listed can be added to the Reading List with a tap and hold, or a swipe action
3. A quick tap on a list item will navigate the user to the `BookDetailView`.

### Reading List Tab

The Reading List tab is represened by the `SavedBooksListView`.

### `BookDetailView`

This is a special view because it spotlights a book selected by the user. The book details are displayed along with a cover image.

From this screen, you can do the following:
1. tap the "plus" button at the top right to add this book to the Reading List
2. tap the book in the "More by this Author" section to reveal a new `BookDetailView`
3. tap the book in the "More from this Subject" section to reveal a new `BookDetailView`


## Data Flow

From the view's perspective, use the `@Enviornment(BookRepository.self)` to fetch for books in the `SearchBookView`.

The primary objective of the `BookRepository` is to be the abstraction for all operations on books that the user interacts with.

Overview of the actions:
- fetch books using the `BookFetcher`
- write/read/delete books using the `BookStore`

### `BookFetcher`

The book fetcher is for abstracting the network layer between the app and any number of different backends. However, in this small use case, we only have `OpenLibraryBookFetcher` which knows how to fetch books using the API as outline in the requirements.

### `BookStore`

The book store is for abstracting where the user's selected books are saved. In this case, we only have one implmenetation which is `LocalBookStore` which read/write/deletes books using SwiftData to the user's device. Additionally, I have setup a minimum boilerplate for migration plan in `DeweyMigrationPlan`.

## Logging

This app does log under the subsystem of `com.ricky-powell.Dewey`. If you would like to filter by that subsystem, please see this artical by Donny Wals for explaination and visuals https://www.donnywals.com/modern-logging-with-the-oslog-framework-in-swift/.

The strategy here is to use the logger as a way to debug and log errors with additional context.

Among the variuos things I have logged for, they include:
- JSON request/response from OpenLibrary api
- errors as they pertain to `BookStore` usage
