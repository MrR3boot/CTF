

<!DOCTYPE html>
<html lang="en" >

<head>

  <meta charset="UTF-8">
  
  <title>Vault | Bank of Spain</title>
  
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/meyer-reset/2.0/reset.min.css">

  
  
<style>
@charset "UTF-8";
@import url("https://fonts.googleapis.com/css2?family=Dongle:wght@300;400;700&family=Montserrat:wght@400;500;700&family=Orbitron&family=Prompt:wght@400;500;700&display=swap");
:root {
  --color-p: #3a5cd1;
  --color-white: #fff;
  --color-light-gray: #eff2f5;
  --color-mid-gray: #96a0b5;
  --color-dark-gray: #6d7d93;
  --color-dark: #182550;
  --color-red: #d13a3a;
}

h1 {
  font-size: 2.441rem;
  line-height: 1.4rem;
}

h2 {
  font-size: 1.953rem;
}

h3 {
  font-size: 1.563rem;
}

h4 {
  font-size: 1.25rem;
}

a {
  text-decoration: none;
  color: var(--color-p);
  transition: all 0.3s ease-out;
}
a:hover {
  color: var(--color-dark);
}

.text-center {
  text-align: center;
}

.text-underline {
  text-decoration: underline;
}

*,
*:before,
*:after {
  box-sizing: border-box;
}

html {
  font-size: 24px;
}

body {
  background: var(--color-light-gray);
  color: var(--color-red);
  font-size: 1‬rem;
  font-family: Dongle, sans-serif;
  line-height: 1.3rem;
}

img,
svg {
  display: block;
  max-width: 100%;
  height: auto;
}

.wrapper {
  min-height: 100vh;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  text-align: center;
}

.left {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  transition: all 0.3s ease-out;
}
.left h1 {
  font-weight: 700;
  margin-bottom: 1rem;
}
.left .social-buttons {
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 0.75rem;
  gap: 1rem;
}
.left .social-buttons a {
  padding: 8px;
  display: inline-block;
  background-color: var(--color-light-gray);
  border-radius: 4px;
}

.left-inner {
  display: flex;
  flex-flow: column wrap;
}




.form-group {
  margin-bottom: 1rem;
  text-align: left;
}

label {
  display: block;
  color: var(--color-dark-gray);
}

input {
  background-color: var(--color-mid-gray);
  padding: 0.5rem;
  border: 1px solid transparent;
  width: 100%;
  border-radius: 6px;
  font-size: 1rem;
  font-family: Dongle, sans-serif;
}
input:focus {
  color: var(--color-dark);
  background-color: var(--color-red);
  border-color: var(--color-p);
  outline: 0;
  border: 1px solid var(--color-p);
}
input.error {
  border: 1.5px solid var(--color-red);
}

.form-radio,
.form-checkbox {
  appearance: none;
  display: inline-block;
  position: relative;
  background-color: var(--color-white);
  border: 2px solid #bdbcc0;
  height: 24px;
  width: 24px;
  border-radius: 50px;
  cursor: pointer;
  margin: 0 10px 0 0;
  outline: none;
  padding: 0;
}

.form-radio:checked::before,
.form-checkbox:checked::before {
  position: absolute;
  left: 5px;
  top: 1px;
  content: "⅃";
  font-size: 14px;
  transform: rotate(40deg);
}

.form-radio:hover,
.form-checkbox:hover {
  background-color: var(--color-mid-gray);
  outline: none;
}

.form-radio:checked,
.form-checkbox:checked {
  background-color: var(--color-p);
  border-color: var(--color-dark);
  color: var(--color-white);
  z-index: 2;
}

.form-radio {
  border: 2px solid #bdbcc0;
  top: 6px;
}

.form-checkbox {
  border-radius: 4px;
}

.error-text {
  color: var(--color-red);
}

.remember-forgot {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.remember {
  display: flex;
  align-items: center;
}
.remember label {
  display: inline-block;
  line-height: 1;
}

.forgot {
  line-height: 1;
  text-align: right;
}

button {
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-red);
  color: var(--color-white);
  border: 0;
  padding: 0.75rem;
  width: 100%;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.75rem;
  cursor: pointer;
  transition: all 0.3s ease-out;
}
button:hover {
  background-color: var(--color-dark);
}

.right {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-white);
  padding-right: 4rem;
}
.right svg {
  margin: auto;
}
.right h2 {
  font-weight: 700;
  margin-bottom: 1.5rem;
}
.right p {
  max-width: 50vw;
  margin: 0 auto;
  line-height: 1rem;
}

.sign-in-form,
.forgot-pass-form,
.sign-up-form {
  display: none;
}
.sign-in-form.active,
.forgot-pass-form.active,
.sign-up-form.active {
  display: block;
}

.dark-mode-btn {
  position: fixed;
  left: 1rem;
  bottom: 1rem;
  z-index: 10;
  background-color: var(--color-white);
  padding: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid var(--color-mid-gray);
  border-radius: 50%;
  transition: all 0.3s ease-out;
}
.dark-mode-btn svg {
  filter: invert(67%) sepia(7%) saturate(757%) hue-rotate(182deg) brightness(95%) contrast(88%);
  width: 16px;
  height: 16px;
}
.dark-mode-btn.active {
  background-color: var(--color-p);
  border-color: var(--color-p);
}
.dark-mode-btn.active svg {
  filter: invert(91%) sepia(31%) saturate(1482%) hue-rotate(328deg) brightness(102%) contrast(101%);
}

.dark-mode-on .left {
  background-color: var(--color-dark);
  color: var(--color-white);
}
.dark-mode-on input {
  background-color: transparent;
  border: 1px solid var(--color-mid-gray);
}
.dark-mode-on .seperator span {
  background-color: var(--color-dark);
}
.dark-mode-on button:hover {
  background-color: var(--color-white);
  color: var(--color-dark);
}

@media screen and (max-width: 48rem) {
  .wrapper {
    grid-template-columns: 1fr;
  }

  .right {
    display: none;
  }
}
</style>

  <script>
  window.console = window.console || function(t) {};
</script>

  
  
  <script>
  if (document.location.search.match(/type=embed/gi)) {
    window.parent.postMessage("resize", "*");
  }
</script>


</head>

<body translate="no" >
  <div class="wrapper">
   <div class="left">
      <div class="left-inner">

         <div class="sign-in-form active">
            <h1>Vault Sign in</h1>
            

            <form action="/doSignIn" method="POST">
               <div class="form-group">
                  <label for="">Username</label>
                  <input type="text" name="username">
               </div>
               <div class="form-group">
                  <label for="">Password</label>
                  <input type="password" name="password">
               </div>
               <div class="form-group remember-forgot">
                  <div class="remember">
                     
                  </div>
                  <div class="forgot">
                     
                  </div>
               </div>
               <div class="form-group">
                  <button>SIGN IN</button>
               </div>
               <div class="create-aacount">
                  
               </div>
            </form>
         </div>

         <div class="forgot-pass-form">
            

            <form action="">
               <div class="form-group">
                  <label for="">E-mail</label>
                  <input type="email" placeholder="@mail.com">
               </div>
               <div class="form-group">
                  <button>RESET PASSWORD</button>
               </div>
               <div class="create-aacount">
                  <a href="javascript:;" class="go-to-sign-in">Go Back</a>
               </div>
            </form>
         </div>
      </div>

    
   </div>
   <div class="right">
      <div class="right-inner">
        <img class="svg" src="https://flxt.tmsimg.com/assets/p14100007_i_h9_aq.jpg" width="1000"/>

         
      </div>
   </div>
</div>


    <script src="https://cpwebassets.codepen.io/assets/common/stopExecutionOnTimeout-1b93190375e9ccc259df3a57c1abc0e64599724ae30d7ea4c6877eb615f89387.js"></script>

  <script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js'></script>
      <script id="rendered-js" >
$(".forgot-pass-link").click(function () {
  $(".sign-in-form").removeClass("active");
  $(".forgot-pass-form").addClass("active");
});

$(".go-to-sign-in").click(function () {
  $(".sign-in-form").addClass("active");
  $(".forgot-pass-form").removeClass("active");
});

$(".sign-up-form-btn").click(function () {
  $(".sign-in-form").removeClass("active");
  $(".sign-up-form").addClass("active");
});

$(".sign-in-form-btn").click(function () {
  $(".sign-in-form").addClass("active");
  $(".sign-up-form").removeClass("active");
});

$(".dark-mode-btn").click(function () {
  $(this).toggleClass("active");
  $("body").toggleClass("dark-mode-on");
});
//# sourceURL=pen.js
    </script>

  

</body>

</html>
 
