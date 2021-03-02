$(document).on('change','#temp-switch',function(){
    if(this.checked)
    {
        $('#celsius').addClass('hidden');
        $('#fahrenheit').removeClass('hidden');
        window.dispatchEvent(new Event('resize'))
    }
    else
    {
        $('#fahrenheit').addClass('hidden');
        $('#celsius').removeClass('hidden');
        window.dispatchEvent(new Event('resize'))
    }
});
$(document).on('change',"[id^='width-switch']",function(){
    if(this.checked)
    {
        $(this).parent().parent().parent().parent().removeClass();
        $(this).parent().parent().parent().parent().addClass('col-md-12');
        window.dispatchEvent(new Event('resize'))
    }
    else
    {
        $(this).parent().parent().parent().parent().removeClass();
        $(this).parent().parent().parent().parent().addClass('col-md-6');
        window.dispatchEvent(new Event('resize'))
    }
});