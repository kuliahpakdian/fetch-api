# Network Troubleshooting Guide

## HTTP 403 Forbidden Error Solutions

### What is HTTP 403?
HTTP 403 Forbidden means the server understood your request but refuses to authorize it. You don't have permission to access the requested resource.

### Common Causes & Solutions

#### 1. **API Rate Limiting**
- **Cause**: Too many requests in a short time period
- **Solution**: 
  - Wait 5-10 minutes before trying again
  - Implement request throttling in your app
  - Use exponential backoff (already implemented in this app)

#### 2. **IP Address Blocked**
- **Cause**: Your IP address has been blocked by the server
- **Solution**:
  - Try using a VPN to change your IP address
  - Contact the API provider if the block persists
  - Check if you're on a corporate network with restrictions

#### 3. **Firewall/Antivirus Blocking**
- **Cause**: Security software blocking network requests
- **Solution**:
  - Temporarily disable firewall/antivirus to test
  - Add your app to firewall exceptions
  - Configure proxy settings if needed

#### 4. **Corporate/Institutional Network Restrictions**
- **Cause**: Network administrator blocking certain domains
- **Solution**:
  - Contact your IT administrator
  - Use mobile hotspot to test
  - Request whitelist for the API domain

#### 5. **API Key Issues**
- **Cause**: Invalid, expired, or missing API key
- **Solution**:
  - Verify API key is correct
  - Check if API key has expired
  - Ensure proper authentication headers

### App Features for Network Troubleshooting

This Flutter app includes several features to help diagnose and resolve network issues:

#### 1. **Automatic Retry with Exponential Backoff**
- Automatically retries failed requests up to 3 times
- Uses increasing delays between retries (2s, 4s, 6s)
- Handles different types of network errors

#### 2. **Network Connectivity Check**
- Tests internet connectivity before making API calls
- Uses DNS lookup to verify network access
- Provides clear error messages for connectivity issues

#### 3. **Detailed Error Messages**
- Specific error messages for different HTTP status codes
- Troubleshooting tips included in error messages
- User-friendly explanations in Indonesian

#### 4. **Network Testing Tools**
- "Test Koneksi" button to diagnose network issues
- Tests both general connectivity and API-specific access
- Shows response times and detailed error information

#### 5. **Platform-Specific Network Configuration**

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<application android:usesCleartextTraffic="true">
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>jsonplaceholder.typicode.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### Manual Testing Steps

1. **Test Internet Connectivity**
   - Open a web browser
   - Try accessing `https://jsonplaceholder.typicode.com/todos/`
   - If it works in browser but not in app, check app permissions

2. **Test with Different Networks**
   - Try mobile data vs WiFi
   - Test with different WiFi networks
   - Use mobile hotspot to isolate network issues

3. **Check System Settings**
   - Verify date/time is correct (affects SSL certificates)
   - Check if any VPN is active
   - Ensure no proxy is configured

4. **Test API Directly**
   ```bash
   curl -v https://jsonplaceholder.typicode.com/todos/
   ```

### Error Code Reference

| Code | Meaning | Common Solutions |
|------|---------|------------------|
| 401 | Unauthorized | Check API credentials |
| 403 | Forbidden | Check permissions, try VPN, wait for rate limit |
| 404 | Not Found | Verify API endpoint URL |
| 429 | Too Many Requests | Wait and retry with backoff |
| 500 | Server Error | Try again later |
| 502 | Bad Gateway | Server issue, try later |
| 503 | Service Unavailable | Server maintenance |

### Development vs Production

**For Development:**
- `android:usesCleartextTraffic="true"` allows HTTP requests
- `NSAllowsArbitraryLoads` allows insecure connections

**For Production:**
- Remove cleartext traffic permissions
- Use HTTPS only
- Implement proper certificate pinning
- Add proper error monitoring

### Additional Resources

- [Flutter Network Documentation](https://docs.flutter.dev/cookbook/networking)
- [HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [JSONPlaceholder API](https://jsonplaceholder.typicode.com/)

### Contact Support

If issues persist:
1. Check the app's error logs
2. Test with the "Test Koneksi" feature
3. Try the troubleshooting steps above
4. Contact your network administrator if on corporate network
