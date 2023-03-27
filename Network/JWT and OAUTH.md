## Authorization vs Authentication


<span style="color:blue">This text is blue</span>


### Authentication:
  
Authentication is the process of verifying the identity of a user, device, or system. It aims to ensure that a user is who they claim to be. Common methods of authentication include:

**Username and password:** The user provides their unique username and a secret password to prove their identity.

**Two-factor authentication (2FA):** In addition to a username and password, the user provides a second factor, such as a one-time code sent to their mobile device or generated by an authenticator app.

**Biometrics**: The user's identity is verified using unique physical characteristics, like fingerprints, facial recognition, or voice recognition.


### Authorization:
Authorization if make sure - the user sent request to the server is the same user is actually logged in during authentication process. 

It is authorizing that this particular user has access to the system. This is normally done via session do you have a session ID that send down in the cookies in the browser. Whenever the user made a request to the server it send that session ID to the server and server checks for its memory with session ID to authorize the user. 

**Standard authorization using browser cookies**

      Clinet (Browser)                                                                            server

                                 post /user/login {with email and password} ------------------>
                                                                                     store User in session in server Memory
                                 send Session ID as Cookie  <------------------
                                 
           (Opening a new page)  send Request with session ID cookie   ------------------>
                                                                                      Get user From the seddion Based on ID And Verify Them
                                 Send Response.    <------------------

Downside for the standard authentication is that the session ID Hass to be stored inside the server which uses memory on the server 


**what is JWT (JSON Web Token)?**

What JWT dues is instead of browser cookies, it uses Jason Webb token for authorization


            Clinet (Browser)                                                                            server

                                 post /user/login {with email and password} ------------------>
                                                                                           Create JWT for user with secret
                                 send JWT to browser  <------------------
                                 
           (Opening a new page)  send Request with JWT   ------------------>
                                                                                      Verify JWT signature and get user from JWT
                                 Send Response.    <------------------



**Why  use JWT?**

Since we are storing the JW token in the client, which is a browser, you can authenticate to different applications using that same JWT token.

**For example,** 
        if a banking web app has a retirement app as well in a totally different server it will same token, which is created when authenticating for the application. You do not have to re-login for different application.


what is OAUTH?


OAuth is an authorization framework that allows third-party applications to obtain limited access to a user's resources on another service without revealing the user's credentials. OAuth 2.0, the current version of the framework, defines a protocol for granting and revoking access tokens, which can be used by the third-party applications to access the protected resources. OAuth 2.0 is not an authentication protocol but can be extended with OpenID Connect (OIDC) to add an authentication layer. The main features of OAuth include:

- Delegated authorization: Users can grant third-party applications access to their resources without sharing their credentials.
- Access control: The level of access can be controlled by issuing tokens with specific scopes, limiting what actions can be performed.
- Revocable access: Access tokens can be revoked by the user or the service at any time.