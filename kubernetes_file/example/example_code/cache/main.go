package main

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"

	"github.com/yuexclusive/utils/kubernetes/example/example_code/proto/hello"
	"github.com/yuexclusive/utils/log"
	"google.golang.org/grpc"

	"github.com/gin-gonic/gin"
	"github.com/yuexclusive/utils/config"
	"github.com/yuexclusive/utils/redis"
)

type Result struct {
	Name string `json:"name"`
}

type Config struct {
	config.Config
}

type handler struct {
	hello.UnimplementedGreeterServer
}

// Sends a greeting
func (h *handler) SayHello(ctx context.Context, req *hello.HelloRequest) (*hello.HelloResponse, error) {
	hostName, err := os.Hostname()

	if err != nil {
		panic(err)
	}
	return &hello.HelloResponse{Message: fmt.Sprintf("hello %s from %s", req.Name, hostName)}, nil
}

func main() {

	config.Init[Config]("./config.toml")

	engine := gin.Default()

	log.GinUseZap(engine)

	cfg := config.Get[Config]()

	redisCfg := &redis.Config{Addr: cfg.Redis.Address}
	if r := redis.InitClient(redisCfg); r != nil {
		log.Panic(r.Error())
	}

	engine.GET("/data", func(c *gin.Context) {
		res := redis.GetClient("").Get("name")
		if err := res.Err(); err != nil {
			c.JSON(http.StatusOK, Result{Name: "no data"})
		} else {
			c.JSON(http.StatusOK, Result{Name: res.Val()})
		}
	})

	go func() {
		server := grpc.NewServer(
			log.GRPCUseZap()...,
		)
		hello.RegisterGreeterServer(server, new(handler))
		listener, err := net.Listen("tcp", ":8081")

		if err != nil {
			panic(err)
		}
		if err := server.Serve(listener); err != nil {
			panic(err)
		}
	}()

	engine.Run(":8080")
}
