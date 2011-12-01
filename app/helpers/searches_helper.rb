module SearchesHelper
  def render_search_results(collection)
   render :partial    => "searches/result",
          :collection => collection,
          :as         => :item
  end
end
