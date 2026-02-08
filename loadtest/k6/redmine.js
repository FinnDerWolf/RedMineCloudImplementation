import http from "k6/http";
import { sleep } from "k6";

export const options = {
  stages: [
    { duration: "30s", target: 10 },
    { duration: "60s", target: 50 },
    { duration: "60s", target: 100 },
    { duration: "30s", target: 0 },
  ],
};

const BASE_URL = __ENV.BASE_URL;

export default function () {
  http.get(`${BASE_URL}/login`);
  sleep(1);
}

