from src.utils.logger import logger

# Steps length ranges
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


def get_converted_distance(weight, height, steps):
    weight_range = get_dog_weight_range(weight)
    step_length_range = get_dog_factor_range(weight)
    fraction = get_position_in_range(weight, weight_range)
    factor = number_in_range(fraction, step_length_range)
    step_length_cm = estimate_step_length(height, factor)
    converted_distance_cm = steps * step_length_cm
    converted_distance_km = converted_distance_cm / 100000  # Convert to kilometers

    return converted_distance_km


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


