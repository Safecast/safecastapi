$(document).on('change','#temp-switch',function(){
    if(this.checked)
    {
        $('#celsius').addClass('hidden');
        $('#fahrenheit').removeClass('hidden');
    }
    else
    {
        $('#fahrenheit').addClass('hidden');
        $('#celsius').removeClass('hidden');
    }
    window.dispatchEvent(new Event('resize'))
});

$(document).on('change','#rad-switch',function(){
    if(this.checked)
    {
        $('#msv').addClass('hidden');
        $('#mrem').removeClass('hidden');
    }
    else
    {
        $('#mrem').addClass('hidden');
        $('#msv').removeClass('hidden');
    }
    window.dispatchEvent(new Event('resize'))
});

$(document).on('change',"[id^='width-switch']",function(){
    if(this.checked)
    {
        setClass($(this),'col-md-12');
    }
    else
    {
        setClass($(this),'col-md-6');
    }
});
function setClass(obj, c)
{
    obj.parent().parent().parent().parent().removeClass();
    obj.parent().parent().parent().parent().addClass(c);
    window.dispatchEvent(new Event('resize'))
}