laaaaBuild a mobile app in Flutter called "Reddit Summarizer." It helps users quickly generate AI-ready prompts to summarize Reddit posts and comments, and directly call an AI API using the same prompt structure.

## Core Features
1. **Input:** A screen where the user pastes a Reddit post URL (e.g., `https://www.reddit.com/r/ClaudeAI/comments/abc123/...`). Validate the URL format.
2. **Fetching:** Use the Reddit public `.json` endpoint (`https://www.reddit.com/r/{subreddit}/comments/{post_id}.json`) to retrieve the post title, body, and all comments. No Reddit API authentication required.
3. **Output Modes (toggleable):**
   - **Mode A – Local Prompt Generator:** Format the fetched content into a structured prompt (see template below). Show a preview and a "Copy" button so the user can paste it into PocketPal or any local AI app.
   - **Mode B – Direct AI Summary:** Call the Sambanova AI API (OpenRouter-compatible) with the same formatted prompt. Display the AI's summary in-app with loading and error states. Also allow copy.
4. **History:** Persist previous summaries (input URL, post title, generated prompt, AI summary if any, timestamp). View, copy, delete from a dedicated screen.
5. **Settings:** Editable API configuration (model name, base URL, API key), pre-populated with the default values below. Store securely.

## Technical Requirements (Exact Stack)
- **Framework:** Flutter latest stable, null safety, Material 3.
- **State Management:** `flutter_bloc` using **Cubits only** (no full BLoC events/event classes). Each feature gets its own Cubit.
- **Error Handling:** `fpdart` – all data layer operations return `Either<Failure, T>` (left for errors, right for success). Define a sealed class `Failure` with subtypes (e.g., `NetworkFailure`, `ServerFailure`, `InvalidInputFailure`).
- **Routing:** `go_router` for declarative navigation with a bottom navigation bar (Input, History, Settings).
- **Architecture:** Clean, feature-first folder structure.
```
lib/
  core/
    errors/failures.dart
    networking/api_client.dart (returns Either)
    theme/
    utils/
    widgets/
  features/
    input/
      cubit/input_cubit.dart
      cubit/input_state.dart
      view/input_page.dart
      widgets/
    output/
      cubit/output_cubit.dart
      cubit/output_state.dart
      view/output_page.dart
      widgets/
    history/
      cubit/history_cubit.dart
      cubit/history_state.dart
      view/history_page.dart
      widgets/
    settings/
      cubit/settings_cubit.dart
      cubit/settings_state.dart
      view/settings_page.dart
  router/
    app_router.dart
main.dart
```
- **Data Flow:** Cubit methods return `Future<void>` and handle `Either` using `fold` or `match`, emitting states accordingly (initial, loading, loaded, error).
- **UI/UX:** Clean, minimal iOS-friendly design, smooth Hero and fade animations, haptic feedback on copy, shimmer loading skeletons, responsive, dark/light mode.

## API Configuration (Mode B)
Default settings (editable in-app):
```yaml
model: "Meta-Llama-3.3-70B-Instruct"
base_url: "https://api.sambanova.ai/v1"
api_key: "your-api-key-here"
```
API client (ApiClient) uses dio or http, wraps calls to POST `{base_url}/chat/completions` with `Authorization: Bearer {api_key}`.

Request body JSON:

```json
{
  "model": "{model}",
  "messages": [
    { "role": "system", "content": "You are a helpful assistant that summarizes Reddit posts and comment threads concisely and insightfully." },
    { "role": "user", "content": "{formatted_prompt}" }
  ],
  "temperature": 0.7,
  "max_tokens": 1000
}
```
Parse response: `choices[0].message.content`. Return `Either<Failure, String>`.

## Local Prompt Template (Mode A & B)
Format the fetched Reddit post data into this exact prompt text:

```text
Here is the full text of a Reddit post and its comments. Please provide a "TL;DR" summary of the post and then a breakdown of the overall sentiment and most interesting points raised in the comments. Write it in the style of a clear, neutral moderator summary.

### Post Title
{title}

### Post Body
{body}

### Comments
{formatted_comments}
```
`formatted_comments`: List top 100 comments sorted by "best" (or top). Show each comment's score, author, and text. Indent replies with `>`. Prefix stickied/mod comments with "MOD NOTE:".

## Important Implementation Details

### Error Handling with fpdart
Example in Cubit:

```dart
Future<void> fetchPost(String url) async {
  emit(state.copyWith(status: OutputStatus.loading));
  final result = await fetchPostAndComments(url); // returns Either<Failure, PostData>
  result.fold(
    (failure) => emit(state.copyWith(status: OutputStatus.error, errorMessage: mapFailureToMessage(failure))),
    (postData) => emit(state.copyWith(status: OutputStatus.loaded, postData: postData)),
  );
}
```

**Routing:** Define `GoRouter` with `ShellRoute` for bottom navigation. Instantiate Cubits using `BlocProvider` at the top of the widget tree. Navigation destinations: `/input`, `/history`, `/settings`. Output screen is a detail page reached by navigating with the post data (pass model via `extra` or through a shared Cubit).

**Persistence:** Use `shared_preferences` or hive for history, `flutter_secure_storage` for API key. History saving should also use `Either` to handle storage failures.

**Dependencies:** `flutter_bloc`, `fpdart`, `go_router`, `dio`, `flutter_secure_storage`, `equatable`, `shimmer`, `haptic_feedback` (or `HapticFeedback.lightImpact()`), `url_launcher` (if needed).

## Deliverable
Generate the complete Flutter project with all files, `pubspec.yaml` listing all dependencies, correct routing, Cubits using fpdart's `Either`, and the feature-first folder structure. Code must be clean, well-commented, compile without errors, and run on iOS.