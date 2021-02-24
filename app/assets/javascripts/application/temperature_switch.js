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