You are an expert iOS and web developer.  Build an iOS app (Swift) that mirrors the Babylon.js Playground using a `WKWebView` to host a web‑based code editor and rendering area.  The app should remain fully web‑compatible (rendering via Babylon.js in the browser) and integrate the Llama‑Stack client for AI assistance.  Please design the project structure, UI and data flow in detail.

**Key requirements**

1. **WebView‑based playground.**
   • The app’s main view uses `WKWebView` to load a local HTML/JavaScript page that replicates the Babylon.js Playground.  The HTML page should implement the four areas seen in the official playground: a menu bar, bottom links bar, a code editor on the left and a render area on the right:contentReference[oaicite:0]{index=0}.  
   • Use the same Babylon.js engine as the web playground.  The editor should leverage Monaco (as in the original) for syntax highlighting and code editing.  The menu must expose actions like Run, Save, Download, New, Clear, Format Code, Metadata, Examples and version selector:contentReference[oaicite:1]{index=1}:contentReference[oaicite:2]{index=2}.  On small screens, collapse this menu into a vertical drawer with items such as Download, Create New, Clear Code, Format Code, Metadata, Examples, WebGL version, etc.:contentReference[oaicite:3]{index=3}.
   • The user can write JavaScript or TypeScript to define a Babylon.js scene.  The web page compiles TypeScript to JavaScript behind the scenes, just as the original playground does:contentReference[oaicite:4]{index=4}.
   • Provide drag‑resizable panes between the editor and the render area, and support full‑screen modes for either pane:contentReference[oaicite:5]{index=5}.
   • Expose JavaScript functions (e.g., `runScene()`, `formatCode()`, `clearCode()`, `saveScene()`) that can be called from Swift via `WKWebView.evaluateJavaScript` to trigger actions like running the code or formatting it.

2. **Swift–Web communication.**
   • Use `WKScriptMessageHandler` to allow the web page to send messages back to Swift.  For example, when the user clicks Save in the web page, post a message that triggers Swift code to store the code locally or upload it.  Also provide messages for events like code changes, errors, or when the scene has finished running.
   • Allow the Llama AI assistant to insert or modify code: expose a JavaScript function `insertCodeAtCursor(codeString)` and call it from Swift when the AI suggests code.

3. **Llama Stack integration (Swift side).**
   • Include the `llama‑stack‑client‑swift` package (v0.2.14):contentReference[oaicite:6]{index=6}.  Use `RemoteInference` for chat completions: initialize it with the inference server URL and optional API key, then stream the model’s response using `chatCompletion`:contentReference[oaicite:7]{index=7}:contentReference[oaicite:8]{index=8}.
   • Use `RemoteAgents` for persistent agentic conversations.  The helper method `initAndCreateTurn` creates an agent, session and turn with a specified model, shields and tools:contentReference[oaicite:9]{index=9}.  Define custom tools (e.g., `insertCode`, `runScene`, `describeScene`) using the `CustomTools` pattern (similar to the example `create_event` tool with name, description and parameters:contentReference[oaicite:10]{index=10}).  Register these tools in the agent’s `client_tools` list.
   • Build a `ChatViewModel` that sends user questions to Llama via `RemoteInference` or `RemoteAgents`, handles streaming responses and tool calls, and updates the chat UI accordingly.  When the agent calls `insertCode`, call the JavaScript function `insertCodeAtCursor` in the WebView.

4. **User actions and saving.**
   • The web page’s Save button should request the Swift side to store the code locally and optionally generate a unique shareable link (e.g., via a backend).  Download should provide a ZIP containing the HTML page with the Babylon.js scene and assets:contentReference[oaicite:11]{index=11}.
   • Provide metadata editing, theme switching, font size adjustment and minimap toggling inside the web page, as described in the Babylon docs:contentReference[oaicite:12]{index=12}.
   • Display compilation errors from the web page to the user (e.g., via a Swift alert).  The web docs explain that errors appear as red pop‑ups in the Playground:contentReference[oaicite:13]{index=13}; implement a similar UI.

5. **Cross‑platform compatibility.**
   • Because the rendering and editor are entirely web‑based, the same HTML/JS can be used in the iOS `WKWebView` and in a regular browser.  Document how to host this page standalone (e.g., using the `full.html` or `frame.html` formats mentioned in the docs:contentReference[oaicite:14]{index=14}).

Please describe the architecture (Swift files, HTML/JS modules), detail how to implement the web page, how to bridge messages between Swift and JavaScript, and provide example Swift code for calling Llama Stack’s `RemoteInference` and streaming responses:contentReference[oaicite:15]{index=15}.  Also outline how to register and handle custom AI tools, and how the AI suggestions will appear in the WebView.

