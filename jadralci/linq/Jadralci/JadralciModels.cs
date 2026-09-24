using System;

namespace Jadralci;

public class Jadralec
{
	public string jid { get; set; } = null!;
	public string ime { get; set; } = null!;
    public int rating { get; set; }
    public double starost { get; set; }
}

public class Coln
{
	public string cid { get; set; } = null!;
	public string ime { get; set; } = null!;
    public int dolzina { get; set; }
    public string barva { get; set; } = null!;
}

public class Rezervacija
{
	public string jid { get; set; } = null!;
	public string cid { get; set; } = null!;
	public DateTime dan { get; set; }
}
