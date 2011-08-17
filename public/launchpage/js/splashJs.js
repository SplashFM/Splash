window.splash	= window.splash || {};


$().ready(function(){
	splash.centerItem('#logo');
	splash.centerItem('#wrapper',true);
	$(window).resize(function(){splash.centerItem('#wrapper',true);});
});

splash.centerItem = function(item,windowCenter){
	windowCenter	=	windowCenter	|| 	false;
	var parentHeight	=	windowCenter ? $(window).height() : $(item).parent().height();
	var thisHeight		=	$(item).height();
	var toMove			=	(parentHeight/2-thisHeight/2)+'px';
	$(item).css({'top':toMove});
}