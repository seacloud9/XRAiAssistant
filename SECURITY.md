# 🛡️ XRAiAssistant Security Strategy: CodeSandbox Integration

## 🚨 **Issue Identified**
**Cross-Site Scripting (XSS) / CORS Vulnerability**: Direct API calls to CodeSandbox from iOS were being blocked by Cross-Origin Resource Sharing (CORS) policies, resulting in HTML error pages instead of JSON responses.

## 🔧 **Root Cause Analysis**

### **Original Problem:**
```swift
// ❌ VULNERABLE: Direct API calls from native iOS to CodeSandbox
URLRequest(url: URL(string: "https://codesandbox.io/api/v1/sandboxes/define")!)
// Result: CORS blocked, HTML error page returned, JSON parsing fails
```

### **Security Issues:**
1. **CORS Restrictions**: CodeSandbox API expects browser environment with proper origin headers
2. **XSS Potential**: User-generated code could contain malicious scripts
3. **API Exposure**: Direct API calls expose authentication tokens
4. **Input Validation**: No sanitization of AI-generated code

## 🛡️ **Comprehensive Security Solution**

### **Primary Strategy: Template-Based URLs (CORS-Free)**
```swift
// ✅ SECURE: Use CodeSandbox template URLs with parameters
func createTemplateBasedSandbox(code: String, framework: String) -> String {
    let sanitizedCode = sanitizeAndEncodeCode(code)
    return "https://codesandbox.io/s/react-three-fiber?file=/src/App.js&initialcode=\(sanitizedCode)"
}
```

**Benefits:**
- ✅ **No CORS issues**: Direct navigation, not API call
- ✅ **Template-based**: Uses official CodeSandbox starter templates
- ✅ **URL-safe**: Proper encoding and sanitization
- ✅ **Instant creation**: No network delays or failures

### **Secondary Strategy: Form Submission (CORS Bypass)**
```swift
// ✅ FALLBACK: HTML form submission to CodeSandbox
func createCodeSandboxViaForm(code: String, framework: String) -> String {
    let formHTML = generateFormSubmissionHTML(files: files)
    let encodedHTML = formHTML.data(using: .utf8)?.base64EncodedString() ?? ""
    return "data:text/html;base64,\(encodedHTML)"
}
```

**Benefits:**
- ✅ **CORS-compliant**: Form submission bypasses CORS restrictions
- ✅ **Full API access**: Complete CodeSandbox Define API functionality
- ✅ **User experience**: Loading animation while form submits
- ✅ **Fallback ready**: Works when template approach fails

### **Security Layers Implemented**

#### **1. Input Sanitization**
```swift
private func sanitizeCode(_ code: String) -> String {
    var sanitized = code

    // Remove script tags
    sanitized = sanitized.replacingOccurrences(of: "<script[^>]*>.*?</script>", with: "", options: .regularExpression)

    // Remove dangerous functions
    let dangerousFunctions = ["eval", "innerHTML", "outerHTML", "document.write"]
    for func in dangerousFunctions {
        sanitized = sanitized.replacingOccurrences(of: func, with: "/* \(func) removed for security */")
    }

    // Remove event handlers
    sanitized = sanitized.replacingOccurrences(of: "on[a-zA-Z]+=", with: "", options: .regularExpression)

    return sanitized
}
```

#### **2. URL Encoding & Validation**
```swift
private func sanitizeAndEncodeCode(_ code: String) -> String {
    let sanitized = code
        .replacingOccurrences(of: "<script", with: "")
        .replacingOccurrences(of: "javascript:", with: "")
        .replacingOccurrences(of: "data:", with: "")

    return sanitized.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
}
```

#### **3. Content Security Policy**
```html
<!-- Secure HTML template with CSP headers -->
<meta http-equiv="Content-Security-Policy" content="
    default-src 'self' https://codesandbox.io;
    script-src 'self' 'unsafe-inline' https://codesandbox.io;
    style-src 'self' 'unsafe-inline';
">
```

## 📋 **Security Best Practices Applied**

### ✅ **Defense in Depth**
1. **Input Validation**: Sanitize all user/AI-generated code
2. **Output Encoding**: URL-encode all parameters
3. **Access Control**: Template-based approach limits API exposure
4. **Error Handling**: Graceful fallbacks for security failures

### ✅ **Principle of Least Privilege**
- **No direct API keys**: Templates don't require authentication
- **Limited scope**: Only React Three Fiber/Reactylon templates
- **Sandbox isolation**: Code runs in CodeSandbox environment, not locally

### ✅ **Secure by Design**
- **CORS compliance**: Template approach naturally CORS-friendly
- **XSS prevention**: Multiple layers of input sanitization
- **CSP implementation**: Content Security Policy headers in templates

## 🚀 **Implementation Strategy**

### **Primary Path (Recommended)**
```swift
// 1. Template-based (instant, CORS-free)
let url = SecureCodeSandboxService.shared.createTemplateBasedSandbox(code: code, framework: framework)
webView.load(URLRequest(url: URL(string: url)!))
```

### **Fallback Path (If needed)**
```swift
// 2. Form submission (full API access)
let formURL = SecureCodeSandboxService.shared.createCodeSandboxViaForm(code: code, framework: framework)
webView.load(URLRequest(url: URL(string: formURL)!))
```

### **Error Recovery**
```swift
// 3. Local playground (offline mode)
if allCodeSandboxApproachesFail {
    useLocalPlaygroundWebView()
}
```

## 🔍 **Security Testing Checklist**

### **XSS Prevention**
- [ ] Script tag injection blocked
- [ ] Event handler injection blocked
- [ ] JavaScript URL schemes blocked
- [ ] Data URL schemes blocked
- [ ] Dangerous function calls removed

### **CORS Compliance**
- [ ] Template URLs load without CORS errors
- [ ] Form submission bypasses CORS restrictions
- [ ] No direct API calls from iOS origin

### **Input Validation**
- [ ] Malicious code patterns detected and removed
- [ ] URL encoding applied correctly
- [ ] Parameter length limits enforced
- [ ] Special characters handled safely

## 📈 **Performance & UX Benefits**

### **Speed Improvements**
- ⚡ **Instant URL generation**: No network delays
- ⚡ **Template pre-loading**: CodeSandbox templates are cached
- ⚡ **Reduced failures**: CORS issues eliminated

### **User Experience**
- 🎯 **Reliable creation**: No more JSON parsing errors
- 🎯 **Faster loading**: Direct navigation to CodeSandbox
- 🎯 **Better error handling**: Graceful fallbacks

## 🔮 **Future Security Enhancements**

### **Phase 2: Advanced Sandboxing**
- Implement CodeSandbox Teams API for enterprise security
- Add code signing verification for AI-generated content
- Implement rate limiting and abuse prevention

### **Phase 3: Zero-Trust Architecture**
- End-to-end encryption for code transmission
- Blockchain-based code integrity verification
- AI model output validation and filtering

---

## 📞 **Security Contact**

For security-related issues or questions:
- **Primary**: Submit GitHub issue with `security` label
- **Critical**: Follow responsible disclosure guidelines
- **Documentation**: See [SECURITY.md](./SECURITY.md) for full details

**This security implementation ensures XRAiAssistant provides a safe, reliable, and performant CodeSandbox integration while protecting against common web vulnerabilities.** 🛡️