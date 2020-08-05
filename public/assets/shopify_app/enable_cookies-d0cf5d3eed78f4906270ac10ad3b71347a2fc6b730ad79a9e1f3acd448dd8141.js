!function(){function e(e){this.itpContent=document.getElementById("TopLevelInteractionContent"),this.itpAction=document.getElementById("TopLevelInteractionButton"),this.redirectUrl=e.redirectUrl}e.prototype.redirect=function(){sessionStorage.setItem("shopify.top_level_interaction",!0),window.location.href=this.redirectUrl},e.prototype.userAgentIsAffected=function(){return Boolean(document.hasStorageAccess)},e.prototype.canPartitionCookies=function(){return/Version\/12\.0\.?\d? Safari/.test(navigator.userAgent)},e.prototype.setUpContent=function(){this.itpContent.style.display="block",this.itpAction.addEventListener("click",this.redirect.bind(this))},e.prototype.execute=function(){this.itpContent&&(this.userAgentIsAffected()?this.setUpContent():this.redirect())},this.ITPHelper=e}(window),function(){function e(e){this.redirectData=e}var t="storage_access_granted",o="storage_access_denied";e.prototype.setNormalizedLink=function(e){return e===t?this.redirectData.hasStorageAccessUrl:this.redirectData.doesNotHaveStorageAccessUrl},e.prototype.redirectToAppTLD=function(e){var t=document.createElement("a");t.href=this.setNormalizedLink(e),data=JSON.stringify({message:"Shopify.API.remoteRedirect",data:{location:t.href}}),window.parent.postMessage(data,this.redirectData.myshopifyUrl)},e.prototype.redirectToAppsIndex=function(){window.parent.location.href=this.redirectData.myshopifyUrl+"/admin/apps"},e.prototype.redirectToAppHome=function(){window.location.href=this.redirectData.appHomeUrl},e.prototype.grantedStorageAccess=function(){try{if(sessionStorage.setItem("shopify.granted_storage_access",!0),document.cookie="shopify.granted_storage_access=true",!document.cookie)throw"Cannot set third-party cookie.";this.redirectToAppHome()}catch(e){console.warn("Third party cookies may be blocked.",e),this.redirectToAppTLD(o)}},e.prototype.handleRequestStorageAccess=function(){return document.requestStorageAccess().then(this.grantedStorageAccess.bind(this),this.redirectToAppsIndex.bind(this,o))},e.prototype.setupRequestStorageAccess=function(){var e=document.getElementById("RequestStorageAccess");document.getElementById("TriggerAllowCookiesPrompt").addEventListener("click",this.handleRequestStorageAccess.bind(this)),e.style.display="block"},e.prototype.handleHasStorageAccess=function(){sessionStorage.getItem("shopify.granted_storage_access")?this.redirectToAppHome():this.redirectToAppTLD(t)},e.prototype.handleGetStorageAccess=function(){sessionStorage.getItem("shopify.top_level_interaction")?this.setupRequestStorageAccess():this.redirectToAppTLD(o)},e.prototype.manageStorageAccess=function(){return document.hasStorageAccess().then(function(e){e?this.handleHasStorageAccess():this.handleGetStorageAccess()}.bind(this))},e.prototype.execute=function(){ITPHelper.prototype.canPartitionCookies()?this.setUpCookiePartitioning():ITPHelper.prototype.userAgentIsAffected()?this.manageStorageAccess():this.grantedStorageAccess()},e.prototype.setUpHelper=function(){return new ITPHelper({redirectUrl:window.shopOrigin+"/admin/apps/"+window.apiKey})},e.prototype.setCookieAndRedirect=function(){document.cookie="shopify.cookies_persist=true",this.setUpHelper().redirect()},e.prototype.setUpCookiePartitioning=function(){document.getElementById("CookiePartitionPrompt").style.display="block",document.getElementById("AcceptCookies").addEventListener("click",this.setCookieAndRedirect.bind(this))},this.StorageAccessHelper=e}(window),document.addEventListener("DOMContentLoaded",function(){var e=document.getElementById("redirection-target"),t=JSON.parse(e.dataset.target);new StorageAccessHelper(t).execute()});