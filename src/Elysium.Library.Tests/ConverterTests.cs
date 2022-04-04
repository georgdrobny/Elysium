using System;
using Xunit;

using FluentAssertions;

namespace Elysium.Library.Tests;

public class ConverterTests
{
    [Fact]
    public void GivenConverter__can_convert_to_string__succeeds()
    {
        // arrange
        var sut = new Converter();
        var date = new DateTime(2017, 1, 1);
        
        // act
        var result = sut.ConvertDateTimeToString(date);
        
        // assert
        result.Should().Be("2017-01-01 00:00:00");
    }
}