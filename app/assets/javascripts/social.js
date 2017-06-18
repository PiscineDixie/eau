/*
* Code pour le login/logout avec Google et facebook
*/

/* deferred loading du javascript de facebook */
(function(d, s, id){
   var js, fjs = d.getElementsByTagName(s)[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement(s); js.id = id;
   js.src = "//connect.facebook.net/fr_CA/sdk.js";
   fjs.parentNode.insertBefore(js, fjs);
 }(document, 'script', 'facebook-jssdk'));

function getCookie(key) {
  var keyValue = document.cookie.match('(^|;) ?' + key + '=([^;]*)(;|$)');
  return keyValue ? keyValue[2] : null;
}

/* callback invoque apres le chargement du facebook js */
window.fbAsyncInit = function() {
  FB.init({
     /* appId      : '1548975615363971', dev account app */
     appId      : '377502229121424',  /* prod account app */
    xfbml      : false,
    version    : 'v2.8',
    cookie     : true
  });
};

/* helper pour logout de facebook */
fbLogout = function() {
  FB.getLoginStatus (function (response) {
    if (response.authResponse) {
      FB.logout(function(response) {
        window.location = '/signout';
      });
    } else {
      window.location = '/signout';
    }
  });
};

/* event handler pour google login callback */
googleSigninCallback = function(authResult) {
  if (authResult['status']['method'] === 'AUTO') {
  } else if (authResult['status']['signed_in']) {
    document.cookie="login=google";
    
    /* Delete this member object because it is not needed and causes
     * a security violation because from another frame */
    delete authResult['g-oauth-window'];
    
    $.post('/auth/google_oauth2/callback', authResult)
      .done(function(data) {
        $('body').html(data);
        socialInitHandlers();
      })
    .fail(function(jqXHR, textStatus) {
      alert("Failed auth processing on server. Please contact support. " + textStatus);
    });
  } else if (authResult['error'] == 'user_signed_out') {
    window.location = '/signout';
  } else if (authResult['error'] == 'immediate_failed') {
    /* Not already log in. Let dialogue take place */
  } else {
    $.post('/auth/failure', {provider: 'google', msg: authResult['error']}, function(data) {
      $('body').html(data);
      socialInitHandlers();
    });
  }
};  

socialLogOut = function(event) {
  var scLg = getCookie('login');
  if (scLg == 'fb') {
    fbLogout();
    event.preventDefault();
  } else if (scLg == 'google') {
    gapi.auth.signOut();
  }
};


facebookSignin = function(event) {
  FB.login(function(response) {
    if (response.status === 'connected') {
      document.cookie="login=fb";
      $.post('/auth/facebook/callback', null)
      .done(function(data) {
        $('body').html(data);
        socialInitHandlers();
      })
      .fail(function(jqXHR, textStatus, errorThrown) {
         $('body').html(jqXHR.responseText); 
      });
    } else {
      var msg;
      if (response.status == 'not_authorized') {
        msg = "Vous devez permettre à l'application d'accéder votre courriel de Facebook.";
      } else {
        msg = "SVP ré-essayer de faire votre login Facebook.";
      }
      $.post('/auth/failure', {provider: 'facebook', msg: msg}, function(data) {
        $('body').html(data);
        socialInitHandlers();
      });
    }
  }, { scope: 'email'});
  event.preventDefault();
};

googleSignIn = function(event) {
  var parms = {
    'clientid' : '1040962372599-s1m9rrdlgdo6bk12u4sjcuq877hvtvk6.apps.googleusercontent.com',
    'cookiepolicy' : 'single_host_origin',
    'scope' : 'profile email',
    'callback' : googleSigninCallback
  };
  gapi.auth.signIn(parms);
  event.preventDefault();
};

socialInitHandlers = function() {
  $('#facebook_signin').click(facebookSignin);
  $('#google_signin').click(googleSignIn);
  $('#sign_out').click(socialLogOut);
};

$(document).ready(function () {
  socialInitHandlers();
});
