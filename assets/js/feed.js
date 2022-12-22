let FeedHooks = {};

FeedHooks.PreviewActivity = {
  mounted() {
    this.el.addEventListener("click", e => {
      e.preventDefault(); // TODO: find a better way to hook a simple event on an anchor without needing a hook
      console.log("PreviewActivity clicked")

      let uri = this.el.dataset.permalink

      let link = e.target.closest('a');
      let button = e.target.closest('button');
      let trigger = this.el.querySelector('.open_preview button')
      const layout = document.getElementById("root")
      const main = document.getElementById("inner")
      const feed = document.querySelector(".feed")


      console.log("feed.scrollTop")
      console.log(layout.scrollTop)


      if (trigger) {
        if (link || button || window.getSelection().toString()) {
          return;
        } else {
          // push event to load up the PreviewContent
          console.log(history)
          this.pushEventTo(this.el.querySelector('.open_preview button'), "open", {}) 
          let previous_scroll = null
          // this.pushEvent("Bonfire.Social.Feeds:open_activity", { id: this.el.dataset.id, permalink: uri })
         
          const preview_content = document.getElementById("preview_content")
          if (feed) {
            previous_scroll = layout.scrollTop
          }
          
          if (preview_content) {
            preview_content.classList.remove("hidden")
          }
          if (main) {
            main.classList.add("hidden")
          }
          history.pushState(
            {
              'previous_url': document.location.href,
              'previous_scroll': previous_scroll
            },
            '',
            uri)
        } 

      }


    })
  }
} 


FeedHooks.Back = {
  mounted() {
    
    if (window.history.length > 1) {
      // show the back icon svg
      this.el.classList.remove("hidden")
      
      this.el.addEventListener("click", e => {
        console.log(window.history)
        e.preventDefault();
        // window.history.back();
      
       })
      } else {
      // se la cronologia del browser è vuota, non fare nulla
    }

    }
}


FeedHooks.ClosePreview = {
  mounted() {

    const back = function () {
      const layout = document.getElementById("root")
      const main = document.getElementById("inner")
      const preview_content = document.getElementById("preview_content")
      if (preview_content) {
        preview_content.classList.add("hidden")
      }
      if (history.state) {
        location_before_preview = history.state["previous_url"]
        previous_scroll = history.state["previous_scroll"]
        main.classList.remove("hidden")
        if (location_before_preview) {
          history.pushState({}, '', location_before_preview)
        }
        if (previous_scroll) {
          layout.scrollTo({ top: previous_scroll, behavior: 'instant' })
          // window.scrollTo(0, previous_scroll);
        }
      }
    }

    // close button
    this.el.addEventListener("click", e => {
      console.log("click - attempt going back")
      back()
    })

    // intercept browser "back" action
    window.addEventListener("popstate", e => {
      console.log("popstate - attempt going back via browser")

      // prevent the app from firing the event
      e.preventDefault();
      console.log("qui")

      // this.pushEvent("Bonfire.UI.Common.OpenPreviewLive:close", {})
      back();
    })
  }
}

export { FeedHooks }

