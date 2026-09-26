using System;
using System.Collections.Generic;

namespace Jadralci;

public static class Utility
{
    public static void Print<T>(IEnumerable<T> items)
    {   
        var properties = typeof(T).GetProperties();

        // Imena stolpcev
        Console.WriteLine(string.Join(" | ", properties.Select(p => $"{p.Name,-15}")));
        Console.WriteLine(new string('-', properties.Length * 18));

        // Vrstice
        foreach (var item in items)
        {
            Console.WriteLine(string.Join(" | ", properties.Select(p => $"{p.GetValue(item),-15}")));
        }
    }
}
