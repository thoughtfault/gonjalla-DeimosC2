// Checks the task status given a task id
func CheckTask(token string, id string) (string, error) {
	params := map[string]interface{}{
		"id": id,
	}

	data, err := Request(token, "check-task", params)
	if err != nil {
		return "", err
	}

	type Response struct {
		id string `json:"id"`
		status string  `json:"status"`
	}

	var response Response
	err = json.Unmarshal(data, &response)
	if err != nil {
		return "", err
	}

	return response.status, nil
}

// Registers a domain given a domain name and desired term length
func RegisterDomain(token string, domain string, years int) (error) {
	params := map[string]interface{}{
		"domain": domain,
		"years": years,
	}

	data, err := Request(token, "register-domain", params)
	if err != nil {
		return err
	}

	type Response struct {
		task string `json:"task"`
	}

	var response Response
	err = json.Unmarshal(data, &response)
	if err != nil {
		return err
	}

	var status string
	for true {
		status, err = CheckTask(token, response.task)
		if err != nil {
			return err
		}

		if status == "active" {
			break
		}

		time.Sleep(5 * time.Second)
	}

	return nil
}
