#!perl6

role Version {
  method version-sum { ... }
}

class Packet does Version {
  has Int $.version;
  has Int $.type-id is rw;

  submethod version-sum { ... }
}

class LiteralPacket is Packet {
  has Int $.value;

  submethod TWEAK() {
    self.type-id = 4;
  }

  submethod result {
    self.value;
  }

  submethod version-sum {
    self.version;
  }
}

class OperatorPacket is Packet {
  has Packet @.subpackets;

  submethod result {
    given self.type-id {
      when 0 { [+]   self.subpackets.map: { .result } }
      when 1 { [*]   self.subpackets.map: { .result } }
      when 2 { [min] self.subpackets.map: { .result } }
      when 3 { [max] self.subpackets.map: { .result } }
      when 5 { 
        self.subpackets[0].result > self.subpackets[1].result ?? 1 !! 0 
      }
      when 6 { 
        self.subpackets[0].result < self.subpackets[1].result ?? 1 !! 0 
      }
      when 7 {
        self.subpackets[0].result == self.subpackets[1].result ?? 1 !! 0 
      }      
    }
  }

  submethod version-sum {
    self.version + [+] self.subpackets.map: { .version-sum };
  }
}

sub hex-to-bits(Str $hex-string) {
  $hex-string.comb
    .map(-> $byte { :16($byte).fmt("%04b") })
    .flatmap(-> $byte { $byte.comb>>.Int });
}

sub bits-to-int(@bits) {
  :2(@bits.join(''));
}

constant $LITERAL_PACKET = 4;

sub parse-packets(@bits, $max-packets = Inf) {
  my @packets; 

  while @bits {
    # the smallest packet is 11 bits
    last if @bits.elems < 11; 

    return @packets 
      unless @packets.elems < $max-packets; 

    my $version = bits-to-int(@bits.splice(0, 3));
    my $type-id = bits-to-int(@bits.splice(0, 3));

    given $type-id {
      # literal packet
      when 4 { 
        my $leading-bit;
        my @literal-bits;
        repeat {
          $leading-bit = @bits.shift();
          @literal-bits.append: @bits.splice(0, 4);
        } until $leading-bit == 0;
                       
        @packets.push:
          LiteralPacket.new(
            version => $version, 
            value => bits-to-int(@literal-bits), 
          );
      }
      # operator packets
      default { 
        my $length-type-id = @bits.shift();

        my @subpackets;
        given $length-type-id {
          # the next 15 bits indicate how long (in bits) the following subpackets are
          when 0 {
            my $subpacket-length-in-bits = bits-to-int(@bits.splice(0, 15));

            @subpackets.append: parse-packets(@bits.splice(0, $subpacket-length-in-bits));
          }
          # the next 11 bits indicate how many subpackets follow this one
          when 1 {
            my $number-of-subpackets = bits-to-int(@bits.splice(0, 11));
          
            @subpackets.append: parse-packets(@bits, $number-of-subpackets);
          }
        }

        @packets.push(
          OperatorPacket.new(
            type-id => $type-id, 
            version => $version,
            subpackets => @subpackets
          )
        );
      }
    }
  }

  @packets;
}

for 'input'.IO.lines -> $hex-string {
  my @bits = hex-to-bits($hex-string);
  my @packets = parse-packets(@bits);

  # part 1 
  say [+] @packets.map: { .version-sum };

  #part 2 
  say @packets[0].result;
}