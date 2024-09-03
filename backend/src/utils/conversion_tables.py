from src.utils.logger import logger

# Steps length ranges in cm
TOY_DOG_STEP_LENGTH = (25, 35)
SMALL_DOG_STEP_LENGTH = (35, 45)
MEDIUM_DOG_STEP_LENGTH = (45, 55)
LARGE_DOG_STEP_LENGTH = (55, 65)
EXTRA_LARGE_DOG_STEP_LENGTH = (65, 80)

# Weight ranges
TOY_DOG_WEIGHT = (2, 5)
SMALL_DOG_WEIGHT = (5, 10)
MEDIUM_DOG_WEIGHT = (10, 25)
LARGE_DOG_WEIGHT = (25, 40)
EXTRA_LARGE_DOG_WEIGHT = (40, 80)

# Factor ranges
TOY_DOG_FACTOR = (0.5, 0.7)
SMALL_DOG_FACTOR = (0.7, 0.9)
MEDIUM_DOG_FACTOR = (0.9, 1.1)
LARGE_DOG_FACTOR = (1.1, 1.3)
EXTRA_LARGE_DOG_FACTOR = (1.3, 1.6)

METABOLIC_SCALING_EXPONENT = 0.75
HOURS_IN_A_DAY = 24
AVERAGE_ACTIVITY_FACTOR = 1.6       # Average activity level
AVERAGE_WALKING_TIME_MINUTES = 60   # Average duration of the walk in minutes
AVERAGE_STEPS_PER_MINUTES = 130


def get_dog_ranges(weight):
    if TOY_DOG_WEIGHT[0] <= weight <= TOY_DOG_WEIGHT[1]:
        return TOY_DOG_WEIGHT, TOY_DOG_STEP_LENGTH, TOY_DOG_FACTOR
    elif SMALL_DOG_WEIGHT[0] <= weight <= SMALL_DOG_WEIGHT[1]:
        return SMALL_DOG_WEIGHT, SMALL_DOG_STEP_LENGTH, SMALL_DOG_FACTOR
    elif MEDIUM_DOG_WEIGHT[0] <= weight <= MEDIUM_DOG_WEIGHT[1]:
        return MEDIUM_DOG_WEIGHT, MEDIUM_DOG_STEP_LENGTH, MEDIUM_DOG_FACTOR
    elif LARGE_DOG_WEIGHT[0] <= weight <= LARGE_DOG_WEIGHT[1]:
        return LARGE_DOG_WEIGHT, LARGE_DOG_STEP_LENGTH, LARGE_DOG_FACTOR
    else:
        return EXTRA_LARGE_DOG_WEIGHT, EXTRA_LARGE_DOG_STEP_LENGTH, EXTRA_LARGE_DOG_FACTOR


def get_dog_step_length_range(weight):
    if TOY_DOG_WEIGHT[0] <= weight <= TOY_DOG_WEIGHT[1]:
        return TOY_DOG_STEP_LENGTH
    elif SMALL_DOG_WEIGHT[0] <= weight <= SMALL_DOG_WEIGHT[1]:
        return SMALL_DOG_STEP_LENGTH
    elif MEDIUM_DOG_WEIGHT[0] <= weight <= MEDIUM_DOG_WEIGHT[1]:
        return MEDIUM_DOG_STEP_LENGTH
    elif LARGE_DOG_WEIGHT[0] <= weight <= LARGE_DOG_WEIGHT[1]:
        return LARGE_DOG_STEP_LENGTH
    elif EXTRA_LARGE_DOG_WEIGHT[0] <= weight <= EXTRA_LARGE_DOG_WEIGHT[1]:
        return EXTRA_LARGE_DOG_STEP_LENGTH
    else:
        return MEDIUM_DOG_FACTOR, MEDIUM_DOG_WEIGHT, MEDIUM_DOG_STEP_LENGTH


def get_dog_weight_range(weight):
    if TOY_DOG_WEIGHT[0] <= weight <= TOY_DOG_WEIGHT[1]:
        return TOY_DOG_WEIGHT
    elif SMALL_DOG_WEIGHT[0] <= weight <= SMALL_DOG_WEIGHT[1]:
        return SMALL_DOG_WEIGHT
    elif MEDIUM_DOG_WEIGHT[0] <= weight <= MEDIUM_DOG_WEIGHT[1]:
        return MEDIUM_DOG_WEIGHT
    elif LARGE_DOG_WEIGHT[0] <= weight <= LARGE_DOG_WEIGHT[1]:
        return LARGE_DOG_WEIGHT
    elif EXTRA_LARGE_DOG_WEIGHT[0] <= weight <= EXTRA_LARGE_DOG_WEIGHT[1]:
        return EXTRA_LARGE_DOG_WEIGHT
    else:
        return MEDIUM_DOG_FACTOR, MEDIUM_DOG_WEIGHT, MEDIUM_DOG_STEP_LENGTH


def get_dog_factor_range(weight):
    if TOY_DOG_WEIGHT[0] <= weight <= TOY_DOG_WEIGHT[1]:
        return TOY_DOG_FACTOR
    elif SMALL_DOG_WEIGHT[0] <= weight <= SMALL_DOG_WEIGHT[1]:
        return SMALL_DOG_FACTOR
    elif MEDIUM_DOG_WEIGHT[0] <= weight <= MEDIUM_DOG_WEIGHT[1]:
        return MEDIUM_DOG_FACTOR
    elif LARGE_DOG_WEIGHT[0] <= weight <= LARGE_DOG_WEIGHT[1]:
        return LARGE_DOG_FACTOR
    elif EXTRA_LARGE_DOG_WEIGHT[0] <= weight <= EXTRA_LARGE_DOG_WEIGHT[1]:
        return EXTRA_LARGE_DOG_FACTOR
    else:
        return MEDIUM_DOG_FACTOR


def get_step_length_range(height):
    if height < 30:  # Height less than 30 cm
        return TOY_DOG_STEP_LENGTH
    elif 30 <= height < 40:     # Height between 30 cm and 40 cm
        return SMALL_DOG_STEP_LENGTH
    elif 40 <= height < 60:     # Height between 40 cm and 60 cm
        return MEDIUM_DOG_STEP_LENGTH
    elif 60 <= height < 80:     # Height between 60 cm and 80 cm
        return LARGE_DOG_STEP_LENGTH
    else:                       # Height 80 cm or more
        return EXTRA_LARGE_DOG_STEP_LENGTH


def get_position_in_range(weight, weight_range):
    start, end = weight_range
    return (weight - start) / (end - start)


def number_in_range(fraction, range_tuple):
    start, end = range_tuple
    if not (0 <= fraction <= 1):
        raise ValueError("Fraction must be between 0 and 1.")
    return start + fraction * (end - start)


def estimate_step_length(height, factor):
    return height * factor


def get_converted_steps(weight, steps_to_convert):
    factor_range = get_dog_factor_range(weight)
    weight_range = get_dog_weight_range(weight)
    fraction = get_position_in_range(weight, weight_range)
    converted_steps = steps_to_convert * number_in_range(fraction, factor_range)

    return converted_steps


def get_calculated_distance(weight, height, steps):
    weight_range, step_length_range, factor_range = get_dog_ranges(weight)
    fraction = get_position_in_range(weight, weight_range)
    factor = number_in_range(fraction, factor_range)
    step_length_cm = height * factor
    distance_cm = steps * step_length_cm
    distance_km = distance_cm / 100000  # Convert cm to km

    return distance_km


def get_burned_calories(weight, distance):
    factor_range = get_dog_factor_range(weight)
    weight_range = get_dog_weight_range(weight)

    fraction = get_position_in_range(weight, weight_range)
    calculated_activity_factor = number_in_range(fraction, factor_range)

    # Estimating BMR (Basal Metabolic Rate) for the dog
    bmr = 70 * (weight ** METABOLIC_SCALING_EXPONENT)

    calories_burned = bmr * calculated_activity_factor * distance / HOURS_IN_A_DAY

    return calories_burned


    # # Constants
    # CALORIES_PER_KG_PER_KM = 1.0  # Approximate calories burned per kg per km
    #
    # # 1. Calculate BMR (Basal Metabolic Rate) - Simplified formula
    # bmr = 70 * (weight ** 0.75)
    #
    # # 2. Calculate calories burned during exercise
    # # Assuming average distance is provided in kilometers
    # calories_burned_exercise = weight * distance * CALORIES_PER_KG_PER_KM
    #
    # # 3. Total Daily Energy Expenditure (TDEE)
    # # if distance <= 0.05:
    # #     tdee = 0
    # # else:
    # tdee = bmr + calories_burned_exercise


def calculate_bcs(steps, weight, height, breed, calories_burned):
    weight_deviation = get_weight_deviation(weight, height, breed)
    caloric_deviation = get_caloric_deviation(weight, calories_burned)
    activity_level = get_activity_level(steps)

    bcs = 5 + 2 * weight_deviation - 1.5 * caloric_deviation - 1 * (1 - activity_level)
    bcs = max(1, min(bcs, 9))

    return round(bcs, 2)


def get_weight_deviation(weight, height, breed):
    weight_ideal = calculate_ideal_weight(breed, height)
    weight_deviation = (weight - weight_ideal) / weight_ideal

    return weight_deviation


def calculate_ideal_weight(breed, height_cm=None):
    breed_weights = {
        "Labrador Retriever": (25, 36),  # min and max weights in kg
        "German Shepherd": (22, 40),
        "Beagle": (9, 11),
        "Golden Retriever": (25, 34),
        "Bulldog": (18, 25),
        "Collie": (18, 30),
        "Dachshund": (4, 6),
        "Husky": (16, 27),
        "Boxer": (25, 32),
        "Doberman Pinscher": (26, 41)
    }

    if breed in breed_weights:
        min_weight, max_weight = breed_weights[breed]
        return (min_weight + max_weight) / 2  # Midpoint of the weight range

    elif height_cm is not None:
        # General formula for height-based estimation (for medium to large breeds)
        return (height_cm - 100) / 2

    else:
        raise ValueError("Breed not recognized and no height provided")


def get_caloric_deviation(weight, calories_burned):
    calculate_maintenance = calculate_maintenance_calories(weight)
    caloric_deviation = (calories_burned - calculate_maintenance) / calculate_maintenance

    return caloric_deviation


def calculate_maintenance_calories(weight):
    # Step 1: Calculate the Resting Energy Requirement (RER)
    rer = 70 * (weight ** 0.75)

    # Step 2: Adjust RER based on how active the dog is to find out the total calories needed
    # MER : Maintenance Energy Requirement
    mer = rer * AVERAGE_ACTIVITY_FACTOR

    return mer


def get_activity_level(steps):
    recommended_steps = AVERAGE_WALKING_TIME_MINUTES * AVERAGE_STEPS_PER_MINUTES

    return steps / recommended_steps
