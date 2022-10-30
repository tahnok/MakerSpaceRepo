/**
 *
 * This JS deals with the navbar
 * The navbar is only in "dark mode" when its on the home page and top of the page and above the media query width to be uncollapsable and the navbar is collapsed
 *
 * These conditions are checked by:
 *  - Checking the navbar for the static pages AND home class. (nav.classList.contains('static_pages') && nav.classList.contains('home'))
 *  - Checking the scrollY of the window, we have a 10px deadzone. (window.scrollY > 10)
 *  - Checking the media query width. As of writing its 1200px (window.matchMedia('(max-width: 1200px)').matches) and (window.matchMedia('(min-width: 1200px)').matches)
 *  - Checking the height of the collapsable navbar (navbarSupportedContent.clientHeight)
 * The transition function has 2 parameters whether we're setting it to dark mode and whether to animate the transition or not.
 */

document.addEventListener("turbolinks:load", function () {
  var nav = document.getElementById("header-navbar");
  var navToggler = document.getElementById("navbar-toggle-button");
  var navbarSupportedContent = document.getElementById(
    "navbarSupportedContent"
  );
  var chevron = document.getElementsByClassName("down-indicator")[0];
  var cc_image_white = document.getElementById("myCcWhite");
  var cc_image_black = document.getElementById("myCcBlack");
  function doTransition(dark, animate) {
    if (
      !(
        nav.classList.contains("static_pages") && nav.classList.contains("home")
      )
    ) {
      return;
    }
    if (typeof animate === "undefined" || animate === true) {
      nav.classList.add("transition");
    }
    if (dark) {
      nav.classList.add("bg-dark-gradient");
      nav.classList.add("navbar-dark");

      nav.classList.remove("navbar-light");
      nav.classList.remove("bg-light");
      if (cc_image_white && cc_image_black) {
        cc_image_white.style.display = "inline";
        cc_image_black.style.display = "none";
      }
    } else {
      nav.classList.add("bg-light");
      nav.classList.add("navbar-light");

      nav.classList.remove("navbar-dark");
      nav.classList.remove("bg-dark-gradient");
      if (cc_image_white && cc_image_black) {
        cc_image_white.style.display = "none";
        cc_image_black.style.display = "inline";
      }
    }
  }

  function check() {
    if (
      !nav.classList.contains("static_pages") &&
      !nav.classList.contains("home")
    ) {
      console.log("1");
      doTransition(false, false);
    } else if (
      navbarSupportedContent.clientHeight > 0 &&
      window.matchMedia("(max-width: 1200px)").matches
    ) {
      console.log("2");
      doTransition(false, false);
    } else if (document.getElementById("flash").clientHeight > 0) {
      console.log("3");
      doTransition(false, false);
    } else {
      console.log("4");
      doTransition(true, false);
    }
  }

  //Not sure if this is necessary anymore, was legacy code when I refactored.
  nav.addEventListener("transitionend", () => {
    nav.classList.remove("transition");
  });
  nav.addEventListener("webkitTransitionEnd", () => {
    nav.classList.remove("transition");
  });
  nav.addEventListener("oTransitionEnd", () => {
    nav.classList.remove("transition");
  });
  nav.addEventListener("otransitionend", () => {
    nav.classList.remove("transition");
  });
  nav.addEventListener("MSTransitionEnd", () => {
    nav.classList.remove("transition");
  });

  // When we scroll past the 10px deadzone, we want to change the navbar to dark mode
  window.addEventListener("scroll", () => {
    doTransition(
      window.scrollY <= 10 &&
        ((window.matchMedia("(max-width: 1200px)").matches &&
          navbarSupportedContent.clientHeight == 0) ||
          window.matchMedia("(min-width: 1200px)").matches),
      true
    );
    if (window.scrollY <= 10 && chevron) {
      chevron.style.opacity = 1;
    } else if (chevron) {
      chevron.style.opacity = 0;
    }
  });

  navToggler.addEventListener("click", () => {
    if (navbarSupportedContent.clientHeight == 0) {
      window.matchMedia("(max-width: 1200px").matches
        ? doTransition(false, false)
        : doTransition(true, false);
    } else {
      window.scrollY < 10
        ? doTransition(true, false)
        : doTransition(false, false);
    }
  });

  window.addEventListener("resize", () => {
    if (
      window.matchMedia("(max-width: 1200px)").matches &&
      navbarSupportedContent.clientHeight > 0
    ) {
      doTransition(false, false);
      return;
    }
    window.scrollY < 10
      ? doTransition(true, false)
      : doTransition(false, false);
  });
  let flashObserver = new ResizeObserver((e) => {
    check();
  });
  flashObserver.observe(document.getElementById("flash"));

  check();
  console.log("11");
});
