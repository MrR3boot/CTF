

<!DOCTYPE html>
<html lang="en" >

<head>

  <meta charset="UTF-8">
  <title>Evidence Book</title>
  
  
<style>
/*general styling*/

@import url('https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,700;1,400;1,700&family=Open+Sans:ital,wght@0,400;0,700;1,400;1,700&display=swap');

* {
    box-sizing: border-box;
}

body {
    padding: 0;
    margin: 0;
    background-color: #000;
    font-family: sans-serif;
}

section#main-container {
    background: #400709;
    min-height: 90vh;
    width: 768px;
    margin: 120px auto;
    padding: 30px;
    line-height: 1.68em;
}

section#main-container #big-logo {
  width: 200px;
}

section#main-container h3 {
  margin-top: 60px;
}




/*header styling*/
header#site-header {
    width: 100%;
    background: #400709;
    padding: 15px 30px;
    transition: all 0.2s ease;
    height: 70px;
    box-shadow: 0 2px 10px #dddddd;
    position: fixed;
    top: 0;
    left: 0;
}

header#site-header a {
    color: #666666;
}

header#site-header a:hover {
    color: #0097ad !important;
    transition: all 0.2s ease;
}

header#site-header button:active {
    position: relative;
    top: 1px;
}

header#site-header div#site-header-auth-container button {
    outline: 0;
    background: transparent;
    height: 30px;
    padding: 0 5px;
    border: 0;
    font-family: "Open Sans", sans-serif;
    font-size: 11pt;
    cursor: pointer;
    color: #666666;
}

header#site-header div#site-header-container {
    display: flex;
    align-items: center;
    height: 40px;
}

header#site-header div#site-header-logo {
    width: auto;
    padding: 0;
    margin-right: 30px;
    height: 30px;
}

header#site-header div#site-header-logo img {
    height: 30px;
}

header#site-header #site-header-search {
    width: auto;
    padding: 0;
    justify-content: flex-end;
    margin-left: auto;
    margin-right: 5px;
}

header#site-header ul#main-menu {
    padding: 0;
}

header#site-header ul#main-menu li {
    list-style: none;
    display: inline;
    margin-right: 10px;
    font-weight: bold;
    font-size: 11pt;
}

header#site-header ul#main-menu li:last-of-type {
    margin-right: 0;
}

header#site-header ul#main-menu li a {
    text-decoration: none;
}

header#site-header .social-buttons {
    margin-top: 10px;
    text-align: center;
    font-size: 14pt;
}

header#site-header .social-buttons i {
    margin-right: 10px;
}

header#site-header .social-buttons i:last-child {
    margin-right: 0;
}

header#site-header #site-header-search {
    flex-grow: 4;
}

header#site-header #site-header-search-container {
    position: relative;
    height: 30px;
    width: 100%;
    padding: 0;
}

header#site-header #site-header-search-container input[type="text"] {
    height: 28px;
    font-size: 12pt;
    font-family: "Open Sans", sans-serif;
    border: none;
    outline: none;
    color: #666666;
    padding-right: 60px;
    width: 0;
    position: absolute;
    top: 0;
    right: 0;
    background: none;
    z-index: 3;
    transition: width .4s cubic-bezier(0.000, 0.795, 0.000, 1.000);
    cursor: pointer;
}

header#site-header #site-header-search-container input[type="text"]:focus:hover {
    border-bottom: 1px solid #0097ad;
}

header#site-header #site-header-search-container input[type="text"]:focus {
    width: calc(100% - 50px);
    z-index: 1;
    border-bottom: 1px solid #999999;
    cursor: text;
    margin-right: 40px;
}

header#site-header #site-header-search-container button#search_submit {
    height: 30px;
    width: 30px;
    border: none;
    color: #999999;
    background: transparent;
    position: absolute;
    top: 0;
    right: 0;
    z-index: 2;
    cursor: pointer;
    transition: opacity 0.3s ease;
    padding: 0;
    font-size: 11pt;
}

header#site-header div#site-header-auth-container {
    justify-content: flex-end;
    text-align: right;
    flex-shrink: 0;
}

header#site-header div#site-header-auth-container .site-header-auth-button:hover {
    border-color: #0097ad;
    color: #0097ad;
    transition: all 0.3s ease;
}

header#site-header div#site-header-auth-container .site-header-auth-button i:after {
    content: "";
    margin-right: 0.32em;
}

/*instead of font icons, to show it on Codepen.
Many thanks to icon8.com */
header#site-header img.icon-header {
  position: relative; 
  top: 3px;
}

/*mobile menu styling*/

#side-menu-container {
    padding-right: 20px;
    transition: all 0.3s ease-in-out;
}

header #side-menu-container #before-side-menu,
header #side-menu-container #after-side-menu {
    display: none;
}

input[type=checkbox]#toggleSideMenu {
    box-sizing: border-box;
    display: none;
}






/*media queries*/

@media screen and (min-width: 1201px) and (max-width: 1500px) {
    /*header#site-header #site-header-search-container input[type="text"]:focus {
        width: 250px;
    }*/
}

@media screen and (max-width: 1200px) {

    /*general styling*/
    .main-container {
        width: 90%;
        overflow: hidden;
        padding: 40px;
    }

    /*to fit the size of the hamburger button*/
    header#site-header {
        height: 60px;
    }

    header#site-header div#site-header-container {
        height: 30px;
    }

    header#site-header div#site-header-logo {
        margin-right: 10px;
        margin-left: 35px;
    }

    /*styling the container for the menu*/
    #side-menu-container {
        position: fixed;
        left: -250px;
        top: 0;
        margin-top: 60px;
        padding: 15px;
        width: 250px;
        height: 100%;
        background: #fff;
        box-shadow: inset -1px 0 5px #eeeeee;
    }

    header #side-menu-container #before-side-menu,
    header #side-menu-container #after-side-menu {
        display: block;
        background: #aaaaaa;
        color: #fff;
        padding: 10px;
    }

    header #side-menu-container #before-side-menu span,
    header #side-menu-container #after-side-menu span {
        font-size: 10pt;
        font-style: italic;
    }

    /*styling the menu inside the <nav> block*/
    #top-menu {
        transition: top 0.5s ease;
        width: 100%;
        margin: 0;
    }

    header#site-header ul#main-menu li {
        display: block;
        width: 100%;
        padding: 15px 20px;
        font-size: 13pt;
        border-bottom: 1px solid #dddddd;
    }

    header#site-header ul#main-menu li:last-of-type {
        border-bottom: none;
    }

    header#site-header ul#main-menu li a {
        margin: 0;
        padding: 0;
    }

    input[type=checkbox]#toggleSideMenu {
        box-sizing: border-box;
        display: none;
    }

    input[type="checkbox"]#toggleSideMenu:checked ~ #side-menu-container {
        transform: translateX(250px);
    }

    /*hamburger icon styling*/
    .hamburger-icon {
        box-sizing: border-box;
        cursor: pointer;
        position: absolute;
        z-index: 99;
        top: 22px;
        left: 22px;
        height: 22px;
        width: 22px;
    }

    .hamburger-menu-line {
        transition: all 0.3s;
        box-sizing: border-box;
        position: absolute;
        height: 3px;
        width: 100%;
        background-color: #666;
    }

    .horizontal {
        box-sizing: border-box;
        position: relative;
        float: left;
        margin-top: 3px;
    }

    .diagonal-1 {
        position: relative;
        box-sizing: border-box;
        float: left;
    }

    .diagonal-2 {
        box-sizing: border-box;
        position: relative;
        float: left;
        margin-top: 3px;
    }

    input[type=checkbox]#toggleSideMenu:checked ~ .hamburger-icon > .horizontal {
        box-sizing: border-box;
        opacity: 0;
    }

    input[type=checkbox]#toggleSideMenu:checked ~ .hamburger-icon > .diagonal-1 {
        box-sizing: border-box;
        transform: rotate(135deg);
        margin-top: 8px;
    }

    input[type=checkbox]#toggleSideMenu:checked ~ .hamburger-icon > .diagonal-2 {
        box-sizing: border-box;
        transform: rotate(-135deg);
        margin-top: -9px;
    }

    header#site-header #site-header-search {
        width: 100%;
    }

}

@media screen and (max-width: 768px) {
    header#site-header div#site-header-auth-container .site-header-auth-button span {
        display: none;
    }

    header#site-header div#site-header-auth-container .site-header-auth-button i::after {
        margin-right: 0;
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
  <header id="site-header">
    <div id="site-header-container">


        <input type="checkbox" class="toggleSideMenu" id="toggleSideMenu" autocomplete="off">
        <label for="toggleSideMenu" class="hamburger-icon">
            <div class="hamburger-menu-line diagonal-1"></div>
            <div class="hamburger-menu-line horizontal"></div>
            <div class="hamburger-menu-line diagonal-2"></div>
        </label>

        <div id="side-menu-container">
            
            <nav id="top-menu">
                <ul id="main-menu" >
                    <li class="main-menu-item"><a href="#">Home</a></li>
                    <li class="main-menu-item"><a href="/book.php">Evidence Book</a></li>
                    <li class="main-menu-item"><a href="#">Catalogue</a></li>
                    <li class="main-menu-item"><a href="#">Contact us</a></li>
                </ul>
            </nav>
           
        </div>

        <div id="site-header-search">
            <div id="site-header-search-container">
                <form action="" autocomplete="on">
                    <input id="search" name="search" type="text" placeholder="Search..."><button id="search_submit" type="submit"><!--i class="icon-search"--><img class ="icon-header" src="https://img.icons8.com/ios-glyphs/20/666666/search--v1.png"/><!--/i--></button>
                </form>
            </div>
        </div>

    </div>
</header>

<section id="main-container">
  
  <h1 style="color: white;">Evidence Book</h1>

        <p style="color:white;">Application to help creating PDF evidences.</p><br>
        <img src='https://static0.srcdn.com/wordpress/wp-content/uploads/2021/10/The-Professor-in-Money-Heist-Season-4.jpg?q=50&fit=crop&w=700&h=481&dpr=1.5'/>
</section>
  
  
  
  

</body>

</html>
 
