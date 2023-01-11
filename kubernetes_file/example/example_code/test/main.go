package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"google.golang.org/grpc"

	"github.com/yuexclusive/utils/config"
	"github.com/yuexclusive/utils/kubernetes/example/example_code/proto/hello"
	"github.com/yuexclusive/utils/log"
	"github.com/yuexclusive/utils/websocket/chat"
)

type Config struct {
	config.Config
}

func main() {
	engine := gin.Default()
	config.Init[Config]("./config.toml")
	log.GinUseZap(engine)

	engine.GET("/metrics", func(c *gin.Context) {
		h := promhttp.Handler()
		h.ServeHTTP(c.Writer, c.Request)
	})

	engine.GET("/foo", func(c *gin.Context) {
		name, err := os.Hostname()

		log.Info("foo msg by hand for test", "name", "jj")

		if err != nil {
			panic(err)
		}
		c.String(http.StatusOK, "%s %s", "foo", name)
	})

	engine.GET("/bar", func(c *gin.Context) {
		name, err := os.Hostname()

		if err != nil {
			panic(err)
		}
		c.String(http.StatusOK, "%s %s", "bar", name)
	})

	engine.GET("/name", func(c *gin.Context) {

		cc := config.Get[Config]()

		c.String(http.StatusOK, "%s %s", "name", cc.Name)
	})

	engine.GET("/name2", func(c *gin.Context) {
		res, err := http.Get("http://cache/data")

		if err != nil {
			c.Error(err)
		}

		bytes := make([]byte, 1<<10)

		n, _ := res.Body.Read(bytes)

		defer res.Body.Close()

		var data Data
		if err := json.Unmarshal(bytes[:n], &data); err != nil {
			c.Error(err)
		}

		c.String(http.StatusOK, data.Name)
	})

	engine.LoadHTMLGlob("*.html")
	engine.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "home.html", nil)
	})

	hub := chat.NewHub()
	go hub.Run()

	engine.GET("/ws", func(c *gin.Context) {
		chat.ServeWs(hub, c.Writer, c.Request)
	})
	engine.GET("/grpc", func(c *gin.Context) {
		cookie := c.GetHeader("cookie")
		targetHost := "cache-grpc" //port is 80
		target := fmt.Sprintf("%s", targetHost)
		if strings.Contains(cookie, "version=v2") {
			target = fmt.Sprintf("%s-v2", targetHost)
		} else {
			target = fmt.Sprintf("%s-v1", targetHost)
		}
		target = fmt.Sprintf("%s:80", target)
		conn, err := grpc.Dial(target, grpc.WithInsecure())
		if err != nil {
			panic(err)
		}
		res, err := hello.NewGreeterClient(conn).SayHello(c, &hello.HelloRequest{Name: "Scarlett"})
		if err != nil {
			c.Error(err)
			return
		}

		hostName, err := os.Hostname()
		if err != nil {
			panic(err)
		}

		c.String(http.StatusOK, fmt.Sprintf("%s--%s", hostName, res.Message))
	})

	engine.GET("/error", func(c *gin.Context) {
		c.String(http.StatusInternalServerError, "test error")
	})

	if err := engine.Run(":8080"); err != nil {
		log.Panic(err.Error())
	}
}

type Data struct {
	Name string `json:"name"`
}
