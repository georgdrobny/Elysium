namespace Elysium.Library;
public class Converter
{
    private readonly string _format;
    
    public Converter(string format = "yyyy-MM-dd HH:mm:ss")
    {
        this._format = format;
    }
    public string ConvertDateTimeToString(DateTime date)
    {
        return date.ToString(this._format);
    }
}
///hallo world