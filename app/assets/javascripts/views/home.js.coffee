class Home extends Page
  renderTop: (content) ->
    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  Home.Router.routes.topTracks()
        label: 'home.top_splashes'}]
      active: content.label)

window.Home = Home
