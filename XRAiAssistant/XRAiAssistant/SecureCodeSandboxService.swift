import Foundation

/// Secure CodeSandbox integration service with multiple fallback strategies
class SecureCodeSandboxService {
    static let shared = SecureCodeSandboxService()

    private init() {}

    // MARK: - Primary Strategy: CodeSandbox Parameters (GET-based)

    /// Create a CodeSandbox using GET parameters (bypasses CORS for direct navigation)
    func createSecureCodeSandboxURL(code: String, framework: String) -> String {
        let files = generateSecureFiles(code: code, framework: framework)
        let parameters = createLZStringParameters(files: files)

        // Use GET-based URL that bypasses CORS restrictions
        return "https://codesandbox.io/s/new?\(parameters)"
    }

    // MARK: - Fallback Strategy: CodeSandbox Define with Form Submission

    /// Create CodeSandbox using a secure form-based approach
    func createCodeSandboxViaForm(code: String, framework: String) -> String {
        let files = generateSecureFiles(code: code, framework: framework)

        // Create a temporary HTML page that submits to CodeSandbox
        let formHTML = generateFormSubmissionHTML(files: files)

        // Return a data URL that can be loaded directly
        let encodedHTML = formHTML.data(using: .utf8)?.base64EncodedString() ?? ""
        return "data:text/html;base64,\(encodedHTML)"
    }

    // MARK: - Enhanced Strategy: Template-based URLs

    /// Use CodeSandbox template URLs (most reliable approach)
    func createTemplateBasedSandbox(code: String, framework: String) -> String {
        print("🌐 Creating secure CodeSandbox using direct API approach for \(framework)")
        print("🔍 Input code preview: \(String(code.prefix(200)))...")

        // Use the new streamlined direct approach first
        let html = createCodeSandboxDirect(code: code, framework: framework)
        print("🔍 Generated direct API HTML length: \(html.count) characters")

        return html
    }

    // MARK: - CodeSandbox Define API Implementation

    /// Streamlined approach: LZ-string compressed form submission
    func createCodeSandboxDirect(code: String, framework: String) -> String {
        let files = generateSecureFiles(code: code, framework: framework)

        // Use the LZ-string compression approach
        return generateFormSubmissionHTML(files: files)
    }

    /// Alternative approach: Create sandbox and return JSON response for debugging
    func createCodeSandboxWithJSONResponse(code: String, framework: String) -> String {
        let files = generateSecureFiles(code: code, framework: framework)
        let filesJSON = generateFilesJSON(files: files)
        let parametersString = createParametersString(filesJSON: filesJSON)

        // Use base64 encoding to safely pass parameters to JavaScript
        let parametersData = parametersString.data(using: .utf8) ?? Data()
        let base64Parameters = parametersData.base64EncodedString()

        // Create HTML that posts to the JSON endpoint for debugging
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Creating CodeSandbox...</title>
            <style>
                body {
                    font-family: system-ui, -apple-system, sans-serif;
                    padding: 20px;
                    background: #f5f5f5;
                }
                .container {
                    max-width: 800px;
                    margin: 0 auto;
                    background: white;
                    padding: 30px;
                    border-radius: 8px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                }
                .status {
                    padding: 15px;
                    margin: 15px 0;
                    border-radius: 4px;
                    border-left: 4px solid;
                }
                .status.loading {
                    background: #e3f2fd;
                    border-color: #2196f3;
                    color: #1565c0;
                }
                .status.success {
                    background: #e8f5e8;
                    border-color: #4caf50;
                    color: #2e7d32;
                }
                .status.error {
                    background: #ffebee;
                    border-color: #f44336;
                    color: #c62828;
                }
                pre {
                    background: #f5f5f5;
                    padding: 15px;
                    border-radius: 4px;
                    overflow-x: auto;
                    white-space: pre-wrap;
                    font-size: 12px;
                }
                .debug-section {
                    margin-top: 30px;
                    border-top: 1px solid #ddd;
                    padding-top: 20px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🚀 XRAiAssistant CodeSandbox Creator</h1>

                <div id="status" class="status loading">
                    <strong>Status:</strong> Preparing sandbox creation...
                </div>

                <div id="result"></div>

                <div class="debug-section">
                    <h3>Debug Information</h3>
                    <h4>Parameters being sent:</h4>
                    <pre id="parameters-debug">\(parametersString.prefix(1000))...</pre>

                    <h4>Files structure:</h4>
                    <pre id="files-debug">\(files.keys.sorted().joined(separator: "\\n"))</pre>
                </div>
            </div>

            <script>
                function updateStatus(message, type = 'loading') {
                    const statusDiv = document.getElementById('status');
                    statusDiv.className = 'status ' + type;
                    statusDiv.innerHTML = '<strong>Status:</strong> ' + message;
                }

                function displayResult(data) {
                    const resultDiv = document.getElementById('result');
                    if (data.sandbox_id) {
                        const sandboxUrl = 'https://codesandbox.io/s/' + data.sandbox_id;
                        resultDiv.innerHTML = `
                            <div class="status success">
                                <strong>✅ Success!</strong> Sandbox created successfully.<br>
                                <a href="${sandboxUrl}" target="_blank" style="color: #2e7d32; font-weight: bold;">${sandboxUrl}</a>
                            </div>
                        `;
                        updateStatus('Sandbox created successfully!', 'success');

                        // Auto-redirect after 3 seconds
                        setTimeout(() => {
                            window.location.href = sandboxUrl;
                        }, 3000);
                    } else if (data.error) {
                        resultDiv.innerHTML = `
                            <div class="status error">
                                <strong>❌ Error:</strong> ${data.error}<br>
                                <pre>${JSON.stringify(data, null, 2)}</pre>
                            </div>
                        `;
                        updateStatus('Failed to create sandbox', 'error');
                    }
                }

                function createSandbox() {
                    updateStatus('Sending request to CodeSandbox...');

                    try {
                        // Decode base64 parameters
                        const base64Params = '\(base64Parameters)';
                        console.log('Base64 params length:', base64Params.length);

                        const parameters = atob(base64Params);
                        console.log('Decoded parameters length:', parameters.length);
                        console.log('Parameters preview:', parameters.substring(0, 200));

                        // Validate JSON
                        const parsedParams = JSON.parse(parameters);
                        console.log('Parameters structure:', Object.keys(parsedParams));

                    fetch('https://codesandbox.io/api/v1/sandboxes/define?json=1', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: parameters
                    })
                    .then(response => {
                        console.log('Response status:', response.status);
                        return response.json();
                    })
                    .then(data => {
                        console.log('CodeSandbox response:', data);
                        displayResult(data);
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        updateStatus('Network error: ' + error.message, 'error');
                        document.getElementById('result').innerHTML = `
                            <div class="status error">
                                <strong>❌ Network Error:</strong> ${error.message}<br>
                                This might be a CORS issue. Falling back to form submission...
                            </div>
                        `;

                        // Fallback to form submission
                        setTimeout(fallbackToForm, 2000);
                    });

                    } catch (parameterError) {
                        console.error('Parameter extraction error:', parameterError);
                        updateStatus('Unable to create CodeSandbox due to parameter extraction error.', 'error');
                        document.getElementById('result').innerHTML = `
                            <div class="status error">
                                <strong>❌ Parameter Error:</strong> ${parameterError.message}<br>
                                <pre>Base64 params: '\(base64Parameters)'</pre>
                            </div>
                        `;
                    }
                }

                function fallbackToForm() {
                    updateStatus('Using form submission fallback...');

                    // Decode base64 parameters for form submission
                    const base64Params = '\(base64Parameters)';
                    const parameters = atob(base64Params);

                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'https://codesandbox.io/api/v1/sandboxes/define';
                    form.target = '_self';

                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'parameters';
                    input.value = parameters;

                    form.appendChild(input);
                    document.body.appendChild(form);
                    form.submit();
                }

                // Start the process
                setTimeout(createSandbox, 1000);
            </script>
        </body>
        </html>
        """

        return html
    }

    // MARK: - Form Submission HTML Generator

    private func generateSimpleFormHTML(files: [String: SecureCodeSandboxFile]) -> String {
        let filesJSON = generateFilesJSON(files: files)
        let parameters = createParametersString(filesJSON: filesJSON)

        // Properly escape the JSON for HTML attributes by base64 encoding it
        let parametersData = parameters.data(using: .utf8) ?? Data()
        let base64Parameters = parametersData.base64EncodedString()

        print("🔧 HTML Generation - Original JSON length: \(parameters.count)")
        print("🔧 HTML Generation - Base64 encoded length: \(base64Parameters.count)")
        print("🔧 HTML Generation - Base64 preview: \(String(base64Parameters.prefix(100)))...")
        print("🔧 HTML Generation - Parameters preview: \(String(parameters.prefix(200)))...")

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Creating CodeSandbox...</title>
            <style>
                body {
                    font-family: system-ui, -apple-system, sans-serif;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                }
                .container {
                    text-align: center;
                    padding: 40px;
                }
                .spinner {
                    border: 3px solid rgba(255,255,255,0.3);
                    border-radius: 50%;
                    border-top: 3px solid white;
                    width: 40px;
                    height: 40px;
                    animation: spin 1s linear infinite;
                    margin: 20px auto;
                }
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h2>🚀 Creating CodeSandbox...</h2>
                <div class="spinner"></div>
                <p id="status">Preparing your React Three Fiber environment...</p>
                <div id="debug-log" style="margin-top: 20px; text-align: left; font-family: monospace; font-size: 12px; background: rgba(0,0,0,0.1); padding: 10px; border-radius: 4px; max-height: 200px; overflow-y: auto;"></div>
            </div>

            <form id="sandbox-form" action="https://codesandbox.io/api/v1/sandboxes/define" method="POST" target="_self" style="display: none;">
                <input type="hidden" name="parameters" value="" id="parameters-input" />
            </form>

            <script>
                // Debug logging
                function debugLog(message) {
                    console.log('CodeSandbox: ' + message);
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.codeSandboxDebug) {
                        window.webkit.messageHandlers.codeSandboxDebug.postMessage(message);
                    }
                }

                debugLog('HTML loaded, preparing form submission');

                // Use base64 parameter decoding (expected by ContentView validation)
                window.addEventListener('load', function() {
                    debugLog('Window loaded, processing base64 parameters');

                    try {
                        // Decode the base64 parameters (this triggers ContentView validation)
                        var base64Params = '\(base64Parameters)';
                        var decodedParams = atob(base64Params);

                        debugLog('Successfully decoded base64 parameters: ' + decodedParams.length + ' characters');

                        // Set the decoded parameters in the form
                        var parametersInput = document.getElementById('parameters-input');
                        if (parametersInput) {
                            parametersInput.value = decodedParams;
                            debugLog('Parameters set in form input');
                        }

                        // Submit the form to codesandbox.io with timeout handling
                        setTimeout(function() {
                            debugLog('Submitting form to codesandbox.io...');
                            debugLog('Parameters size: ' + decodedParams.length + ' characters');

                            var form = document.getElementById('sandbox-form');
                            if (form) {
                                // Add a timeout warning
                                setTimeout(function() {
                                    debugLog('⏰ Form submission taking longer than expected...');
                                    document.body.innerHTML += '<div style="position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:rgba(255,255,255,0.9);padding:20px;border-radius:8px;color:#333;z-index:9999;">⏰ Creating sandbox... This may take a moment.</div>';
                                }, 3000);

                                form.submit();
                                debugLog('Form submitted successfully');
                            } else {
                                debugLog('❌ Form not found');
                            }
                        }, 1000);

                    } catch (error) {
                        debugLog('❌ Error processing base64 parameters: ' + error.message);
                    }
                });
            </script>
        </body>
        </html>
        """
    }

    private func generateFormSubmissionHTML(files: [String: SecureCodeSandboxFile]) -> String {
        let filesJSON = generateFilesJSON(files: files)
        let parametersString = createParametersString(filesJSON: filesJSON)

        // Base64 encode the JSON to safely pass it through JavaScript string interpolation
        let parametersData = parametersString.data(using: .utf8) ?? Data()
        let base64Parameters = parametersData.base64EncodedString()

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Creating CodeSandbox...</title>
            <meta charset="utf-8">
            <style>
                body {
                    font-family: system-ui, -apple-system, sans-serif;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                }
                .container {
                    text-align: center;
                    padding: 40px;
                }
                .spinner {
                    border: 3px solid rgba(255,255,255,0.3);
                    border-radius: 50%;
                    border-top: 3px solid white;
                    width: 40px;
                    height: 40px;
                    animation: spin 1s linear infinite;
                    margin: 20px auto;
                }
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h2>🚀 Creating CodeSandbox...</h2>
                <div class="spinner"></div>
                <p>Redirecting to your live React Three Fiber environment...</p>
            </div>

            <form id="sandbox-form" action="https://codesandbox.io/api/v1/sandboxes/define" method="POST" target="_self">
                <input type="hidden" name="parameters" value="\(createParametersString(filesJSON: filesJSON))" />
            </form>

            <script>
                // LZ-string compression library (minimal implementation)
                var LZString=function(){var r=String.fromCharCode,o="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",n="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-$",e={};function t(r,o,n,e,t,s,u){var a,i,l,C=0,f=0,c=0,A={},h={},p={},v="",d="",g="",m=2,w=3,b=2,y=[],S=0,x=0;for(l=0;l<r.length;l+=1)if(v=r.charAt(l),Object.prototype.hasOwnProperty.call(A,v)||(A[v]=w++,h[v]=!0),d=g+v,Object.prototype.hasOwnProperty.call(A,d))g=d;else{if(Object.prototype.hasOwnProperty.call(h,g)){if(g.charCodeAt(0)<256){for(a=0;a<b;a++)S<<=1,x==n-1?(x=0,y.push(s(S)),S=0):x++;for(i=g.charCodeAt(0),a=0;a<8;a++)S=S<<1|1&i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i>>=1}else{for(i=1,a=0;a<b;a++)S=S<<1|i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i=0;for(i=g.charCodeAt(0),a=0;a<16;a++)S=S<<1|1&i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i>>=1}0==--C&&(C=Math.pow(2,b),b++),delete h[g]}else for(i=A[g],a=0;a<b;a++)S=S<<1|1&i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i>>=1;0==--C&&(C=Math.pow(2,b),b++),A[d]=w++,g=String(v)}if(""!==g){if(Object.prototype.hasOwnProperty.call(h,g)){if(g.charCodeAt(0)<256){for(a=0;a<b;a++)S<<=1,x==n-1?(x=0,y.push(s(S)),S=0):x++;for(i=g.charCodeAt(0),a=0;a<8;a++)S=S<<1|1&i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i>>=1}else{for(i=1,a=0;a<b;a++)S=S<<1|i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i=0;for(i=g.charCodeAt(0),a=0;a<16;a++)S=S<<1|1&i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i>>=1}0==--C&&(C=Math.pow(2,b),b++),delete h[g]}else for(i=A[g],a=0;a<b;a++)S=S<<1|1&i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i>>=1;0==--C&&(C=Math.pow(2,b),b++)}for(i=2,a=0;a<b;a++)S=S<<1|1&i,x==n-1?(x=0,y.push(s(S)),S=0):x++,i>>=1;for(;;){if(S<<=1,x==n-1){y.push(s(S));break}x++}}return y.join("")}return e={compressToBase64:function(r){if(null==r)return"";var n=t(r,6,function(r){return o.charAt(r)});switch(n.length%4){default:case 0:return n;case 1:return n+"===";case 2:return n+"==";case 3:return n+"="}},compressToUTF16:function(o){return null==o?"":t(o,15,function(o){return r(o+32)})+" "},compressToUint8Array:function(r){var o=t(r,8,function(r){return r});return new Uint8Array(o)},compressToEncodedURIComponent:function(r){return null==r?"":t(r,6,function(r){return n.charAt(r)})},compress:function(o){return t(o,16,function(o){return r(o)})}}}();

                // Debug logging
                function debugLog(message) {
                    console.log('CodeSandbox: ' + message);
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.codeSandboxDebug) {
                        window.webkit.messageHandlers.codeSandboxDebug.postMessage(message);
                    }
                }

                // Update visual status
                var statusEl = document.getElementById('status');
                if (statusEl) {
                    statusEl.textContent = message;
                }

                // Add to debug log
                var debugEl = document.getElementById('debug-log');
                if (debugEl) {
                    var logLine = document.createElement('div');
                    logLine.textContent = new Date().toLocaleTimeString() + ': ' + message;
                    debugEl.appendChild(logLine);
                    debugEl.scrollTop = debugEl.scrollHeight;
                }

                debugLog('HTML loaded, preparing LZ-compressed form submission');

                // Use LZ-string compression for CodeSandbox parameters
                window.addEventListener('load', function() {
                    debugLog('Window loaded, creating compressed form submission');

                    // Use base64 encoded JSON to safely pass through JavaScript string interpolation
                    var base64Json = '\(base64Parameters)';
                    debugLog('Base64 JSON length: ' + base64Json.length + ' characters');

                    try {
                        var jsonParams = atob(base64Json);
                        debugLog('Successfully decoded base64. JSON length: ' + jsonParams.length + ' characters');
                        debugLog('JSON preview: ' + jsonParams.substring(0, 100) + '...');
                    } catch (error) {
                        debugLog('❌ Failed to decode base64: ' + error.message);
                        return;
                    }

                    // Compress using LZ-string for CodeSandbox compatibility
                    try {
                        var compressedParams = LZString.compressToBase64(jsonParams);
                        debugLog('LZ-String compression successful. Compressed length: ' + compressedParams.length + ' characters');
                        debugLog('Compression ratio: ' + Math.round((compressedParams.length / jsonParams.length) * 100) + '%');
                    } catch (error) {
                        debugLog('❌ LZ-String compression failed: ' + error.message);
                        return;
                    }

                    // Create form programmatically
                    var form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'https://codesandbox.io/api/v1/sandboxes/define';
                    form.target = '_self';

                    var input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'parameters';
                    input.value = compressedParams;

                    form.appendChild(input);
                    document.body.appendChild(form);

                    debugLog('Form created successfully. About to submit to CodeSandbox...');
                    debugLog('Form action: ' + form.action);
                    debugLog('Form method: ' + form.method);
                    debugLog('Parameters length: ' + compressedParams.length);

                    try {
                        form.submit();
                        debugLog('✅ Form submitted successfully! Redirecting to CodeSandbox...');
                    } catch (error) {
                        debugLog('❌ Form submission failed: ' + error.message);
                    }
                });
            </script>
        </body>
        </html>
        """
    }

    // MARK: - Secure File Generation

    private func generateSecureFiles(code: String, framework: String) -> [String: SecureCodeSandboxFile] {
        let sanitizedCode = sanitizeCode(code)

        switch framework {
        case "reactThreeFiber":
            return generateSecureReactThreeFiberFiles(userCode: sanitizedCode)
        case "reactylon":
            return generateSecureReactylonFiles(userCode: sanitizedCode)
        default:
            return generateSecureThreeJSFiles(userCode: sanitizedCode)
        }
    }

    private func sanitizeCode(_ code: String) -> String {
        // Security: Remove potentially dangerous code patterns
        var sanitized = code

        // Remove script tags
        sanitized = sanitized.replacingOccurrences(of: "<script[^>]*>.*?</script>", with: "", options: .regularExpression)

        // Remove dangerous functions
        let dangerousFunctions = ["eval", "innerHTML", "outerHTML", "document.write"]
        for functionName in dangerousFunctions {
            sanitized = sanitized.replacingOccurrences(of: functionName, with: "/* \(functionName) removed for security */")
        }

        // Remove event handlers
        sanitized = sanitized.replacingOccurrences(of: "on[a-zA-Z]+=", with: "", options: .regularExpression)

        return sanitized
    }

    private func sanitizeCodeForJSON(_ code: String) -> String {
        // First apply general security sanitization
        let sanitized = sanitizeCode(code)

        // Additional JSON-specific sanitization
        // These shouldn't normally be in React code, but just to be safe
        // Note: We don't escape quotes here because JSONSerialization handles that

        print("🔍 Code sanitization: original length \(code.count), sanitized length \(sanitized.count)")

        return sanitized
    }

    private func generateSecureThreeJSFiles(userCode: String) -> [String: SecureCodeSandboxFile] {
        let packageJson = """
        {
          "name": "xraiassistant-threejs-scene",
          "version": "1.0.0",
          "description": "XRAiAssistant Three.js Scene",
          "keywords": ["threejs", "3d", "webgl"],
          "main": "src/index.js",
          "dependencies": {
            "three": "0.171.0"
          },
          "devDependencies": {
            "parcel": "2.12.0"
          },
          "scripts": {
            "start": "parcel src/index.html",
            "build": "parcel build src/index.html --public-url ./"
          }
        }
        """

        // Use simple vanilla Three.js approach - no React complications
        let indexJs = """
        import * as THREE from 'three';

        // Create the basic Three.js scene
        const scene = new THREE.Scene();
        const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        const renderer = new THREE.WebGLRenderer({ antialias: true });

        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.setClearColor(0x222222);
        document.body.appendChild(renderer.domElement);

        // Add basic lighting
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
        scene.add(ambientLight);

        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight.position.set(5, 5, 5);
        scene.add(directionalLight);

        // User's custom code (converted to Three.js if needed)
        try {
          // Execute user code in Three.js context
          \(userCode)
        } catch (error) {
          console.warn('User code failed, using fallback:', error);

          // Fallback: Create a simple animated cube
          const geometry = new THREE.BoxGeometry(1, 1, 1);
          const material = new THREE.MeshPhongMaterial({
            color: 0x00ff88,
            shininess: 100
          });
          const cube = new THREE.Mesh(geometry, material);
          scene.add(cube);

          // Animation for the fallback cube
          function animateFallback() {
            requestAnimationFrame(animateFallback);
            cube.rotation.x += 0.01;
            cube.rotation.y += 0.01;
            renderer.render(scene, camera);
          }
          animateFallback();
        }

        // Set camera position
        camera.position.z = 5;

        // Basic animation loop
        function animate() {
          requestAnimationFrame(animate);
          renderer.render(scene, camera);
        }
        animate();

        // Handle window resize
        window.addEventListener('resize', () => {
          camera.aspect = window.innerWidth / window.innerHeight;
          camera.updateProjectionMatrix();
          renderer.setSize(window.innerWidth, window.innerHeight);
        });

        // Add info overlay
        const info = document.createElement('div');
        info.style.cssText = `
          position: absolute;
          top: 10px;
          left: 10px;
          color: white;
          font-family: Arial, sans-serif;
          font-size: 12px;
          background: rgba(0,0,0,0.7);
          padding: 8px 12px;
          border-radius: 4px;
          z-index: 1000;
        `;
        info.textContent = '🎨 XRAiAssistant - Three.js Scene';
        document.body.appendChild(info);

        console.log('✅ Three.js scene initialized successfully');
        """

        return [
            "package.json": SecureCodeSandboxFile(content: packageJson),
            "src/index.js": SecureCodeSandboxFile(content: indexJs),
            "src/index.html": SecureCodeSandboxFile(content: generateSecureIndexHTML())
        ]
    }

    private func generateSecureReactThreeFiberFiles(userCode: String) -> [String: SecureCodeSandboxFile] {
        let packageJson = """
        {
          "name": "r3f-scene",
          "version": "1.0.0",
          "main": "src/index.js",
          "keywords": ["react", "three", "3d"],
          "dependencies": {
            "react": "^18.2.0",
            "react-dom": "^18.2.0",
            "@react-three/fiber": "^8.15.19",
            "@react-three/drei": "^9.88.13",
            "three": "^0.158.0"
          }
        }
        """

        // Create proper React Three Fiber entry point
        print("🔍 SecureCodeSandboxService - Injecting user code of length: \(userCode.count)")
        print("🔍 User code preview: \(String(userCode.prefix(100)))...")

        // Sanitize user code to prevent JSON encoding issues
        let sanitizedUserCode = sanitizeCodeForJSON(userCode)

        let indexJs = sanitizedUserCode

        print("🔍 Generated index.js length: \(indexJs.count)")
        print("🔍 Index.js preview: \(String(indexJs.prefix(100)))...")

        return [
            "package.json": SecureCodeSandboxFile(content: packageJson),
            "src/index.js": SecureCodeSandboxFile(content: generateReactEntry()),
            "src/App.js": SecureCodeSandboxFile(content: indexJs),
            "public/index.html": SecureCodeSandboxFile(content: generateStandardReactHTML()),
            "sandbox.config.json": SecureCodeSandboxFile(content: generateReactSandboxConfig())
        ]
    }

    private func generateSecureReactylonFiles(userCode: String) -> [String: SecureCodeSandboxFile] {
        // Similar structure for Reactylon with Babylon.js dependencies
        // Implementation would be similar to R3F but with Babylon.js packages
        return generateSecureThreeJSFiles(userCode: userCode) // Simplified for now
    }

    private func generateSecureIndexHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>XRAiAssistant Three.js Scene</title>
            <style>
              body {
                margin: 0;
                padding: 0;
                overflow: hidden;
                background: #222222;
                font-family: Arial, sans-serif;
              }
            </style>
          </head>
          <body>
            <script src="./src/index.js"></script>
          </body>
        </html>
        """
    }

    private func generateSecureReactIndexHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>XRAiAssistant React Three Fiber Scene</title>
            <style>
              body {
                margin: 0;
                padding: 0;
                overflow: hidden;
                background: #222222;
                font-family: Arial, sans-serif;
              }
              #root {
                width: 100vw;
                height: 100vh;
              }
            </style>
          </head>
          <body>
            <div id="root"></div>
            <script src="./index.jsx"></script>
          </body>
        </html>
        """
    }

    private func generateParcelSandboxConfig() -> String {
        return """
        {
          "template": "react",
          "container": {
            "port": 1234,
            "node": "18",
            "startScript": "start"
          },
          "infiniteLoopProtection": true,
          "hardReloadOnChange": false,
          "view": "browser"
        }
        """
    }

    private func generateReactSandboxConfig() -> String {
        return """
        {
          "template": "react",
          "infiniteLoopProtection": true,
          "hardReloadOnChange": false,
          "view": "browser"
        }
        """
    }

    private func generateReactEntry() -> String {
        return """
        import React from "react";
        import ReactDOM from "react-dom/client";
        import App from "./App";

        const rootElement = document.getElementById("root");
        const root = ReactDOM.createRoot(rootElement);

        root.render(<App />);
        """
    }

    private func generateStandardReactHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>React Three Fiber Scene</title>
            <style>
              body {
                margin: 0;
                padding: 0;
                overflow: hidden;
                background: #000;
                font-family: Arial, sans-serif;
              }
              #root {
                width: 100vw;
                height: 100vh;
              }
            </style>
          </head>
          <body>
            <div id="root"></div>
          </body>
        </html>
        """
    }

    private func generateViteIndexHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>XRAiAssistant React Three Fiber Scene</title>
            <style>
              body {
                margin: 0;
                padding: 0;
                overflow: hidden;
                background: #222222;
                font-family: Arial, sans-serif;
              }
              #root {
                width: 100vw;
                height: 100vh;
              }
            </style>
          </head>
          <body>
            <div id="root"></div>
            <script type="module" src="/src/main.jsx"></script>
          </body>
        </html>
        """
    }

    private func generateViteConfig() -> String {
        return """
        import { defineConfig } from 'vite'
        import react from '@vitejs/plugin-react'

        export default defineConfig({
          plugins: [react()],
          server: {
            port: 3000,
            host: true
          },
          optimizeDeps: {
            include: ['three', '@react-three/fiber', '@react-three/drei']
          }
        })
        """
    }

    private func generateViteSandboxConfig() -> String {
        return """
        {
          "template": "vite-react",
          "container": {
            "port": 5173,
            "node": "18",
            "startScript": "dev"
          },
          "infiniteLoopProtection": true,
          "hardReloadOnChange": false,
          "view": "browser"
        }
        """
    }

    private func generateSandboxConfig() -> String {
        return """
        {
          "template": "parcel",
          "container": {
            "port": 1234,
            "node": "18"
          }
        }
        """
    }

    // MARK: - Parameter Generation Helpers

    private func createLZStringParameters(files: [String: SecureCodeSandboxFile]) -> String {
        // For now, return empty - would implement LZ-string compression
        return ""
    }

    private func createParametersString(filesJSON: String) -> String {
        // CodeSandbox Define API expects a specific format with the files wrapped in the correct structure
        do {
            // First parse the filesJSON to ensure it's valid JSON
            guard let filesData = filesJSON.data(using: .utf8) else {
                print("❌ Invalid files JSON - cannot convert to data")
                return "{\"error\": \"Invalid files JSON\"}"
            }

            let filesObject = try JSONSerialization.jsonObject(with: filesData)

            // Create the proper parameters structure expected by CodeSandbox
            let parameters = [
                "files": filesObject
            ]

            let parametersData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let parametersString = String(data: parametersData, encoding: .utf8) ?? "{}"

            print("🔧 Creating parameters string - Final length: \(parametersString.count) characters")
            print("🔧 Parameters structure: \(parametersString.prefix(200))...")

            return parametersString
        } catch {
            print("❌ Error creating parameters string: \(error)")
            return "{\"error\": \"Failed to create parameters\"}"
        }
    }

    private func generateFilesJSON(files: [String: SecureCodeSandboxFile]) -> String {
        // Convert files to JSON format expected by CodeSandbox Define API
        // All file contents should be strings, even package.json
        var jsonDict: [String: [String: Any]] = [:]

        for (path, file) in files {
            // CodeSandbox expects all files to have string content
            // Special handling for package.json - if it's valid JSON, parse and re-stringify it for proper formatting
            if path == "package.json" {
                if let packageData = file.content.data(using: .utf8),
                   let packageJSON = try? JSONSerialization.jsonObject(with: packageData),
                   let prettyData = try? JSONSerialization.data(withJSONObject: packageJSON, options: [.prettyPrinted]),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    // Use pretty-printed JSON string as content
                    jsonDict[path] = [
                        "content": prettyString,
                        "isBinary": file.isBinary
                    ]
                } else {
                    // Fallback to original string content if JSON parsing fails
                    jsonDict[path] = [
                        "content": file.content,
                        "isBinary": file.isBinary
                    ]
                }
            } else {
                // All other files use string content as-is
                // Debug: Check for problematic content
                if path == "src/main.jsx" {
                    print("🔍 Processing main.jsx with content length: \(file.content.count)")
                    print("🔍 Main.jsx content preview: \(String(file.content.prefix(200)))...")
                }

                jsonDict[path] = [
                    "content": file.content,
                    "isBinary": file.isBinary
                ]
            }
        }

        // CodeSandbox Define API expects just the files object, not wrapped in another object
        do {
            // Debug: Check the structure before serialization
            print("🔍 About to serialize \(jsonDict.keys.count) files")
            for (key, value) in jsonDict {
                if let content = value["content"] as? String {
                    print("🔍 File \(key): \(content.count) characters")
                }
            }

            let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

            print("🔍 Generated files JSON length: \(jsonString.count)")
            print("🔍 Files JSON starts with: \(String(jsonString.prefix(100)))")
            print("🔍 Files structure: \(jsonDict.keys.sorted())")

            // Validate that we can parse it back
            if let testData = jsonString.data(using: .utf8),
               let _ = try? JSONSerialization.jsonObject(with: testData) {
                print("✅ Generated files JSON validates successfully")
                return jsonString
            } else {
                print("❌ Generated files JSON failed validation")
                return "{\"error\": \"JSON generation failed\"}"
            }
        } catch {
            print("❌ JSON serialization error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            // Try to identify which content is problematic
            for (key, value) in jsonDict {
                if let content = value["content"] as? String {
                    if content.contains("\"") || content.contains("\\") {
                        print("❌ Potentially problematic content in \(key): contains quotes or backslashes")
                    }
                }
            }
            return "{\"error\": \"JSON serialization failed: \\(error.localizedDescription)\"}"
        }
    }
}

// MARK: - Supporting Types

struct SecureCodeSandboxFile {
    let content: String
    let isBinary: Bool

    init(content: String, isBinary: Bool = false) {
        self.content = content
        self.isBinary = isBinary
    }
}

enum SecureCodeSandboxError: Error, LocalizedError {
    case corsRestriction
    case invalidResponse
    case securityViolation
    case templateNotFound

    var errorDescription: String? {
        switch self {
        case .corsRestriction:
            return "Cross-origin request blocked by security policy"
        case .invalidResponse:
            return "Invalid response from CodeSandbox service"
        case .securityViolation:
            return "Code contains potentially unsafe content"
        case .templateNotFound:
            return "CodeSandbox template not available"
        }
    }
}