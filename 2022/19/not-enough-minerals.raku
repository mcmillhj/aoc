#!raku 

enum Robot <ORE-BOT CLAY-BOT OBSIDIAN-BOT GEODE-BOT>;
enum Resource <ORE CLAY OBSIDIAN GEODE>;

class Blueprint {
  has Int $.id;
  has Int $.ore-robot-ore-cost;
  has Int $.clay-robot-ore-cost;
  has Int $.obsidian-robot-ore-cost;
  has Int $.obsidian-robot-clay-cost;
  has Int $.geode-robot-ore-cost;
  has Int $.geode-robot-obsidian-cost;

  method WHICH {
    return join "-", 
      self.id, self.ore-robot-ore-cost, self.clay-robot-ore-cost, self.obsidian-robot-ore-cost, 
      self.obsidian-robot-clay-cost, self.geode-robot-ore-cost, self.geode-robot-obsidian-cost;
  }

  method Str {
    self.WHICH
  }
}

class Factory {
  has Blueprint $.blueprint; 
  has Int %.resources{Resource} is rw = (
    Resource::ORE      => 0,
    Resource::CLAY     => 0,
    Resource::OBSIDIAN => 0,
    Resource::GEODE    => 0,
  );
  has Int %.robots{Robot} is rw = (
    Robot::ORE-BOT      => 1,
    Robot::CLAY-BOT     => 0,
    Robot::OBSIDIAN-BOT => 0,
    Robot::GEODE-BOT    => 0,
  );
  has Robot @!build-queue; 

  method cost(Robot $robot, Resource $resource) {
    do given $robot, $resource {
      when Robot::ORE-BOT, Resource::ORE        { self.blueprint.ore-robot-ore-cost        }
      when Robot::CLAY-BOT, Resource::ORE       { self.blueprint.clay-robot-ore-cost       }
      when Robot::OBSIDIAN-BOT, Resource::ORE   { self.blueprint.obsidian-robot-ore-cost   }
      when Robot::OBSIDIAN-BOT, Resource::CLAY  { self.blueprint.obsidian-robot-clay-cost  }
      when Robot::GEODE-BOT, Resource::ORE      { self.blueprint.geode-robot-ore-cost      }
      when Robot::GEODE-BOT, Resource::OBSIDIAN { self.blueprint.geode-robot-obsidian-cost }
      default { 0 }
    }
  }

  method can-build(Robot $robot --> Bool) {
    do given $robot {
      when Robot::ORE-BOT {
        self.resources{Resource::ORE} >= self.cost(Robot::ORE-BOT, Resource::ORE)
      }
      when Robot::CLAY-BOT {
        self.resources{Resource::ORE} >= self.cost(Robot::CLAY-BOT, Resource::ORE)
      }
      when Robot::OBSIDIAN-BOT {
        self.resources{Resource::ORE} >= self.cost(Robot::OBSIDIAN-BOT, Resource::ORE) 
          and self.resources{Resource::CLAY} >= self.cost(Robot::OBSIDIAN-BOT, Resource::CLAY)
      }
      when Robot::GEODE-BOT {
        self.resources{Resource::ORE} >= self.cost(Robot::GEODE-BOT, Resource::ORE) 
          and self.resources{Resource::OBSIDIAN} >= self.cost(Robot::GEODE-BOT, Resource::OBSIDIAN)
      }
      default {
        False
      }
    }
  }

  method start-building(Robot $robot) {
    given $robot {
      when Robot::ORE-BOT { 
        self.resources{Resource::ORE} -= self.cost(Robot::ORE-BOT, Resource::ORE);

        @!build-queue.push: Robot::ORE-BOT;
      }
      when Robot::CLAY-BOT {
        self.resources{Resource::ORE} -= self.cost(Robot::CLAY-BOT, Resource::ORE);

        @!build-queue.push: Robot::CLAY-BOT;
      }
      when Robot::OBSIDIAN-BOT {
        self.resources{Resource::ORE} -= self.cost(Robot::OBSIDIAN-BOT, Resource::ORE);
        self.resources{Resource::CLAY} -= self.cost(Robot::OBSIDIAN-BOT, Resource::CLAY);

        @!build-queue.push: Robot::OBSIDIAN-BOT;
      }
      when Robot::GEODE-BOT {
        self.resources{Resource::ORE} -= self.cost(Robot::GEODE-BOT, Resource::ORE);
        self.resources{Resource::OBSIDIAN} -= self.cost(Robot::GEODE-BOT, Resource::OBSIDIAN);

        @!build-queue.push: Robot::GEODE-BOT;
      }
    }
  }

  method finish-building() {
    for @!build-queue -> Robot $robot {
      self.robots{$robot} += 1;
    }

    @!build-queue = ();
  }

  method harvest() {
    for self.robots.keys -> Robot $robot {
      given $robot {
        when Robot::ORE-BOT { 
          self.resources{Resource::ORE} += self.robots{Robot::ORE-BOT} 
        }
        when Robot::CLAY-BOT { 
          self.resources{Resource::CLAY} += self.robots{Robot::CLAY-BOT} 
        }
        when Robot::OBSIDIAN-BOT { 
          self.resources{Resource::OBSIDIAN} += self.robots{Robot::OBSIDIAN-BOT} 
        }
        when Robot::GEODE-BOT { 
          self.resources{Resource::GEODE} += self.robots{Robot::GEODE-BOT} 
        }
      }
    }
  }
}

my @blueprints = 'input'.IO.lines.map(-> $line {
  my (Int() $blueprint-id) := $line ~~ m/'Blueprint ' (\d+)/;
  my (Int() $ore-robot-ore-cost) := $line ~~ m/'Each ore robot costs ' (\d+)/;
  my (Int() $clay-robot-ore-cost) := $line ~~ m/'Each clay robot costs ' (\d+)/;
  my (Int() $obsidian-robot-ore-cost, Int() $obsidian-robot-clay-cost) := $line ~~ m/'Each obsidian robot costs ' (\d+) ' ore and ' (\d+)/;
  my (Int() $geode-robot-ore-cost, Int() $geode-robot-obsidian-cost) := $line ~~ m/'Each geode robot costs ' (\d+) ' ore and ' (\d+)/;

  Blueprint.new(
    id                        => $blueprint-id, 
    ore-robot-ore-cost        => $ore-robot-ore-cost, 
    clay-robot-ore-cost       => $clay-robot-ore-cost, 
    obsidian-robot-ore-cost   => $obsidian-robot-ore-cost, 
    obsidian-robot-clay-cost  => $obsidian-robot-clay-cost, 
    geode-robot-ore-cost      => $geode-robot-ore-cost, 
    geode-robot-obsidian-cost => $geode-robot-obsidian-cost
  );
});

sub simulate(Factory $factory, Int $minutes) {
  for 1 .. $minutes -> $minute {
    # random number between 0 and 1
    my $r = rand; 

    # we want to maximize geode-bots so always make geode bots if possible 
    if $factory.can-build(Robot::GEODE-BOT) {
      $factory.start-building(Robot::GEODE-BOT);
    }
    # divide the remaining three build actions: build obsidian-bot, build clay-bot, build ore-bot, build nothing into equally probable buckets
    elsif $r <= 0.25 and $factory.can-build(Robot::OBSIDIAN-BOT) {
      $factory.start-building(Robot::OBSIDIAN-BOT);
    }
    elsif $r <= 0.5 and $factory.can-build(Robot::CLAY-BOT) {
      $factory.start-building(Robot::CLAY-BOT);
    }
    elsif $r <= 0.75 and $factory.can-build(Robot::ORE-BOT) {
      $factory.start-building(Robot::ORE-BOT);
    } 
    else {
      # build nothing
    }

    # all robots gather resources
    $factory.harvest();

    # finish building any robots that started construction during this minute
    $factory.finish-building();
  }

  $factory.resources{Resource::GEODE};
}

# part 1
say [+] @blueprints.map(-> $blueprint {
  $blueprint.id * max([^500_000].map(-> $iteration {
    simulate(Factory.new(blueprint => $blueprint), 24);
  }));
});


# part 2
# Note: this is _very_ slow. ~250K record per 10 minutes.
say [*] @blueprints.head(3).map(-> $blueprint {
  max([^5_000_000].map(-> $iteration {
    say "Blueprint $($blueprint.id), Iteration $iteration..." if $iteration mod 250_000 === 0;
    simulate(Factory.new(blueprint => $blueprint), 32)  
  }));
});