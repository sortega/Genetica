module Genetica
  class Population

    attr_reader :chromosome_population

    # Population attributes
    attr_accessor :crossover_probability
    attr_accessor :mutation_probability
    attr_accessor :fitness_function
    # Chromosome attributes
    attr_accessor :chromosome_alleles    

    def initialize(chromosome_population)
      @chromosome_population = chromosome_population
    end
    
    def fitness_proportionate_selection
      # Get an array with chromosome fitness      
      chromosome_fitness = @chromosome_population.collect { |chromosome| @fitness_function.call(chromosome) }

      # FUTURE: With Ruby 1.9.3 you can use rand with ranges, e.g. rand 0.0..3.4
      # Get random number
      random_generator = Random.new
      random_number = random_generator.rand 0.0..chromosome_fitness.inject(:+)

      # Chromosome selection
      fitness_counter = 0
      @chromosome_population.each_with_index do |chromosome, i|
        fitness_counter += chromosome_fitness[i]
        if fitness_counter >= random_number
          return chromosome
        end
      end
    end

    def run(generations=1)
      generations.times do
        # Generate a new chromosome population
        chromosome_population = Array.new

        while chromosome_population.size < @chromosome_population.size
          # 1. Selection Step
          # Select a pair of parent chromosomes from the current population.
          # This selection is 'with replacement', the same chromosome can be selected
          # more than once to become a parent.
          chromosome_a = self.fitness_proportionate_selection
          chromosome_b = self.fitness_proportionate_selection

          # 2. Crossover Step
          # TODO: Maybe crossover probability check would be in the single_point_crossover of
          # Chromosome class.
          if rand.between? 0, @crossover_probability
            offspring_a, offspring_b = chromosome_a.single_point_crossover chromosome_b
          else
            offspring_a, offspring_b = chromosome_a, chromosome_b
          end

          # 3. Mutation Step
          offspring_a.mutate! @mutation_probability, @chromosome_alleles
          offspring_b.mutate! @mutation_probability, @chromosome_alleles

          # 4. Adding offsprings to new chromosome population
          chromosome_population << offspring_a << offspring_b
        end

        # Replacing chromosome population with the new one
        @chromosome_population = chromosome_population

      end
    end

  end
end
