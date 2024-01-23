def update_values(resources):
    for k, r in resources.items():
        if r.resource_type == "bool":
            continue

        v = r.get_value()
        r.set_value(v + 1)
    return
